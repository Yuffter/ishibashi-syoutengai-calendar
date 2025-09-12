import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackathon/model/store_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';

// StoreImageの状態を管理するState
class StoreImageState {
  final List<StoreImageModel> images;
  final bool isLoading;
  final String? error;
  final DateTime? lastFetched;

  const StoreImageState({
    this.images = const [],
    this.isLoading = false,
    this.error,
    this.lastFetched,
  });

  StoreImageState copyWith({
    List<StoreImageModel>? images,
    bool? isLoading,
    String? error,
    DateTime? lastFetched,
  }) {
    return StoreImageState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastFetched: lastFetched ?? this.lastFetched,
    );
  }
}

// StoreImageViewModel
class StoreImageViewModel extends StateNotifier<StoreImageState> {
  static const String _cacheBoxName = 'store_images_cache';
  static const String _cacheKey = 'images_data';
  static const String _timestampKey = 'last_fetch_timestamp';
  static const Duration _cacheExpiration = Duration(minutes: 30); // 30分キャッシュ

  StoreImageViewModel() : super(const StoreImageState()) {
    fetchImages();
  }

  Future<void> fetchImages() async {
    try {
      state = state.copyWith(isLoading: true);

      // キャッシュが有効かチェック
      if (await _isCacheValid()) {
        final cachedImages = await _loadFromCache();
        print('キャッシュから読み込み');
        if (cachedImages.isNotEmpty) {
          final lastFetched = await _getLastFetchTime();
          state = state.copyWith(
            images: cachedImages,
            isLoading: false,
            lastFetched: lastFetched,
          );
          return;
        }
      }

      // Firestoreから取得
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('date', descending: true)
          .get();

      final images = snapshot.docs.map((doc) {
        final data = doc.data();
        return StoreImageModel(
          id: doc.id,
          imageUrl: data['url'] ?? '',
          storeName: data['shop_name'] ?? '',
          eventDate: (data['date'] as Timestamp).toDate(),
          title: data['title'] ?? '',
          description: data['description'] ?? '',
        );
      }).toList();

      // キャッシュに保存
      await _saveToCache(images);
      final now = DateTime.now();

      state = state.copyWith(
        images: images,
        isLoading: false,
        lastFetched: now,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // キャッシュが有効かどうかをチェック
  Future<bool> _isCacheValid() async {
    try {
      final box = await Hive.openBox(_cacheBoxName);
      final timestamp = box.get(_timestampKey);
      if (timestamp == null) return false;

      final lastFetch = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      return now.difference(lastFetch) < _cacheExpiration;
    } catch (e) {
      return false;
    }
  }

  // キャッシュからデータを読み込み
  Future<List<StoreImageModel>> _loadFromCache() async {
    try {
      final box = await Hive.openBox(_cacheBoxName);
      final cachedData = box.get(_cacheKey);
      if (cachedData == null) return [];

      return (cachedData as List).map((item) {
        final data = Map<String, dynamic>.from(item);
        return StoreImageModel(
          id: data['id'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          storeName: data['storeName'] ?? '',
          eventDate: DateTime.fromMillisecondsSinceEpoch(
            data['eventDate'] ?? 0,
          ),
          title: data['title'] ?? '',
          description: data['description'] ?? '',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // キャッシュにデータを保存
  Future<void> _saveToCache(List<StoreImageModel> images) async {
    try {
      final box = await Hive.openBox(_cacheBoxName);
      final cacheData = images
          .map(
            (image) => {
              'id': image.id,
              'imageUrl': image.imageUrl,
              'storeName': image.storeName,
              'eventDate': image.eventDate.millisecondsSinceEpoch,
              'title': image.title,
              'description': image.description,
            },
          )
          .toList();

      await box.put(_cacheKey, cacheData);
      await box.put(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // キャッシュ保存に失敗しても処理は続行
      print('Cache save failed: $e');
    }
  }

  // 最終取得時刻を取得
  Future<DateTime?> _getLastFetchTime() async {
    try {
      final box = await Hive.openBox(_cacheBoxName);
      final timestamp = box.get(_timestampKey);
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      return null;
    }
  }

  // キャッシュを強制的にクリア
  Future<void> clearCache() async {
    try {
      final box = await Hive.openBox(_cacheBoxName);
      await box.clear();
    } catch (e) {
      print('Cache clear failed: $e');
    }
  }

  // 画像情報を追加
  void addStoreImage(StoreImageModel storeImage) {
    state = state.copyWith(images: [...state.images, storeImage]);
  }

  // 画像情報を更新
  void updateStoreImage(String id, StoreImageModel updatedImage) {
    final updatedImages = state.images.map((image) {
      return image.id == id ? updatedImage : image;
    }).toList();

    state = state.copyWith(images: updatedImages);
  }

  // 画像情報を削除
  void removeStoreImage(String id) {
    final filteredImages = state.images
        .where((image) => image.id != id)
        .toList();
    state = state.copyWith(images: filteredImages);
  }

  // Firestoreから画像情報を削除（データベース、Firebase Storage、ローカル状態から削除）
  Future<bool> deleteStoreImage(String id) async {
    try {
      // 削除対象の画像情報を取得
      final imageToDelete = state.images.firstWhere(
        (image) => image.id == id,
        orElse: () => throw Exception('削除対象の画像が見つかりません'),
      );

      // Firebase Storageから画像を削除
      if (imageToDelete.imageUrl.isNotEmpty) {
        try {
          final storageRef = FirebaseStorage.instance.refFromURL(
            imageToDelete.imageUrl,
          );
          await storageRef.delete();
        } catch (storageError) {
          // Storage削除に失敗してもFirestore削除は続行
          print('Storage削除エラー: $storageError');
        }
      }

      // Firestoreから削除
      await FirebaseFirestore.instance.collection('events').doc(id).delete();

      // ローカル状態からも削除
      removeStoreImage(id);

      // キャッシュも更新
      await _saveToCache(state.images);

      return true;
    } catch (e) {
      state = state.copyWith(error: 'イベントの削除に失敗しました: $e');
      return false;
    }
  }

  // 店舗名で検索
  List<StoreImageModel> getImagesByStoreName(String storeName) {
    return state.images
        .where(
          (image) =>
              image.storeName.toLowerCase().contains(storeName.toLowerCase()),
        )
        .toList();
  }

  // 日付で検索
  List<StoreImageModel> getImagesByDate(DateTime date) {
    return state.images
        .where(
          (image) =>
              image.eventDate.year == date.year &&
              image.eventDate.month == date.month &&
              image.eventDate.day == date.day,
        )
        .toList();
  }

  // ローディング状態を設定
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  // エラー状態を設定
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  // すべてのデータをクリア
  void clearAll() {
    state = const StoreImageState();
  }
}

// Provider
final storeImageViewModelProvider =
    StateNotifierProvider<StoreImageViewModel, StoreImageState>(
      (ref) => StoreImageViewModel(),
    );

// 店舗名一覧を取得するProvider
final storeNamesProvider = Provider<List<String>>((ref) {
  final images = ref.watch(storeImageViewModelProvider).images;
  final storeNames = images.map((image) => image.storeName).toSet().toList();
  storeNames.sort();
  return storeNames;
});

// 特定の日付の画像を取得するProvider
final imagesByDateProvider = Provider.family<List<StoreImageModel>, DateTime>((
  ref,
  date,
) {
  final viewModel = ref.read(storeImageViewModelProvider.notifier);
  return viewModel.getImagesByDate(date);
});
