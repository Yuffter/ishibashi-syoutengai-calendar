import 'package:flutter/material.dart';
import 'package:hackathon/model/store_image.dart';
import 'calendar_view.dart';

class EventDetailView extends StatelessWidget {
  final StoreImageModel event;

  const EventDetailView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('イベント詳細'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('タイトル: ${event.title}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('説明: ${event.description}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text('店舗名: ${event.storeName}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text('開催日: ${event.eventDate.toLocal().toString().split(' ')[0]}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Image.network(event.imageUrl, height: 200, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }
}
