import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackathon/model/store_image.dart';
import 'package:hackathon/view_model/user_status.dart';

class EventDetailView extends ConsumerWidget {
  final StoreImageModel event;
  const EventDetailView({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ログイン状態を取得
    final isLoggedIn = ref.watch(userStatusViewModelProvider).isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFfef8ff),
        surfaceTintColor: const Color(0xFFfef8ff),
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'イベント詳細',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          // ログインしている場合のみ削除ボタンを表示
          if (isLoggedIn == true)
            Padding(
              padding: const EdgeInsets.only(right: 10), // reduce the default right spacing
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text(
                            "投稿の削除",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: const Text("このイベントを削除しますか？"),
                          actionsAlignment: MainAxisAlignment.spaceBetween,
                          actions: [
                            TextButton(
                              child: const Text("キャンセル"),
                              onPressed: () {
                                Navigator.of(dialogContext).pop(false);
                              },
                            ),
                            TextButton(
                              child: const Text(
                                "削除",
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                Navigator.of(dialogContext).pop(true);
                              },
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed == true) {
                      // 詳細画面は直接Providerを操作せず、削除要求を返す
                      if (context.mounted) {
                        Navigator.of(context).pop({'deleted': true, 'id': event.id});
                      }
                    }
                  },
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                    maxWidth: 400,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[600]!, width: 4.0),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      event.imageUrl,
                      height: 400,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 400,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            // borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 400,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 60,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                '画像を読み込めませんでした',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      filterQuality: FilterQuality.high,
                      isAntiAlias: true,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '店舗名: ${event.storeName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '開催日: ${event.eventDate.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  '${event.title}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SingleChildScrollView(
                    child: Text(
                      '${event.description}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
