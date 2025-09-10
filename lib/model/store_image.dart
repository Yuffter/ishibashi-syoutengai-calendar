
class StoreImageModel {
  final String id;
  final String imageUrl;
  final String storeName; // 店舗名
  final DateTime eventDate; // 日付
  final String title; // タイトル
  final String description; // 概要

  StoreImageModel({
    required this.id,
    required this.imageUrl,
    required this.storeName,
    required this.eventDate,
    required this.title,
    required this.description,
  });

  // JSONから作成
  factory StoreImageModel.fromJson(Map<String, dynamic> json) {
    return StoreImageModel(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      storeName: json['storeName'] as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  // JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'storeName': storeName,
      'eventDate': eventDate.toIso8601String(),
      'title': title,
      'description': description,
    };
  }

  // コピーコンストラクタ
  StoreImageModel copyWith({
    String? id,
    String? imageUrl,
    String? storeName,
    DateTime? eventDate,
    String? title,
    String? description,
  }) {
    return StoreImageModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      storeName: storeName ?? this.storeName,
      eventDate: eventDate ?? this.eventDate,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}
