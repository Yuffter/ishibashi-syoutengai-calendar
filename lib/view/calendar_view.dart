import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackathon/view_model/user_status.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widget/store_image_form_modal.dart';
import 'package:hackathon/view_model/store_image.dart';
import 'event-detail-view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TableCalendarSample(),
    );
  }
}

class TableCalendarSample extends ConsumerStatefulWidget {
  const TableCalendarSample({super.key});

  @override
  ConsumerState<TableCalendarSample> createState() =>
      _TableCalendarSampleState();
}

class _TableCalendarSampleState extends ConsumerState<TableCalendarSample> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(storeImageViewModelProvider).images;

    // イベントがある日を時刻なしDateでまとめる
    final eventDates = images
        .map(
          (image) => DateTime(
            image.eventDate.year,
            image.eventDate.month,
            image.eventDate.day,
          ),
        )
        .toSet();
    final isLoggedIn = ref.watch(userStatusViewModelProvider).isLoggedIn;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isLoggedIn == true && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(2030, 1, 1),
            focusedDay: _focusedDay,
            locale: 'ja_JP',
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final normalizedDate = DateTime(
                  date.year,
                  date.month,
                  date.day,
                );
                final hasEvent = eventDates.contains(normalizedDate);

                if (!hasEvent) return const SizedBox.shrink();

                return Positioned(
                  bottom: 0,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.grey, // ドットの色
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final images = ref.watch(storeImageViewModelProvider);
                final filtered = images.images
                    .where((img) => isSameDay(img.eventDate, _selectedDay))
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('この日のイベントはありません'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) {
                                return FractionallySizedBox(
                                  heightFactor: 0.90,
                                  widthFactor: 1.0,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    child: EventDetailView(event: item),
                                  ),
                                );
                              },
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: SizedBox(
                                    height: 200,
                                    child: Image.network(
                                      item.imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          width: double.infinity,
                                          height: 180,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: double.infinity,
                                              height: 180,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                              ),
                                              child: const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.broken_image,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                                  Text(
                                                    '画像を読み込めませんでした',
                                                    style: TextStyle(
                                                      color: Colors.grey,
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
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 1行目：店舗名
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '店舗名: ${item.storeName}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (isLoggedIn == true)
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.red, width: 1.5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.close, color: Colors.red, size: 24),
                                                padding: EdgeInsets.zero,
                                                onPressed: () async {
                                                  final shouldDelete = await showDialog<bool>(
                                                    context: context,
                                                    builder: (ctx) => AlertDialog(
                                                      title: const Text(
                                                        '削除の確認',
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      content: const Text('このイベントを削除してもよろしいですか？'),
                                                      actions: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(ctx, false),
                                                              child: const Text('キャンセル'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(ctx, true),
                                                              child: const Text('削除'),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );

                                                  if (shouldDelete == true) {
                                                    try {
                                                      // Firestore のドキュメントを削除
                                                      await FirebaseFirestore.instance
                                                          .collection('storeImages')
                                                          .doc(item.id)
                                                          .delete();

                                                      // ローカルステートも更新
                                                      ref.read(storeImageViewModelProvider.notifier).removeStoreImage(item.id);
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text('削除に失敗しました')),
                                                      );
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // 2行目：タイトルと日付
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.title,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                color: Color.fromARGB(
                                                  255,
                                                  112,
                                                  112,
                                                  112,
                                                ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${item.eventDate.month}月${item.eventDate.day}日',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isLoggedIn == true
          ? Padding(
              padding: const EdgeInsets.only(right: 5, bottom: 5),
              child: SizedBox(
                width: 72,
                height: 72,
                child: FloatingActionButton(
                  onPressed: () {
                    showStoreImageFormModal(context);
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, size: 36),
                ),
              ),
            )
          : null,
    );
  }
}
