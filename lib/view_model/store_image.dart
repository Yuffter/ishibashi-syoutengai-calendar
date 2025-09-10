import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackathon/model/store_image.dart';

// StoreImageの状態を管理するState
class StoreImageState {
  final List<StoreImageModel> images;
  final bool isLoading;
  final String? error;

  const StoreImageState({
    this.images = const [],
    this.isLoading = false,
    this.error,
  });

  StoreImageState copyWith({
    List<StoreImageModel>? images,
    bool? isLoading,
    String? error,
  }) {
    return StoreImageState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// StoreImageViewModel
class StoreImageViewModel extends StateNotifier<StoreImageState> {
  StoreImageViewModel() : super(const StoreImageState());

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
