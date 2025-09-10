import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackathon/view_model/user_status.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../widget/store_image_form_modal.dart';
import 'package:hackathon/model/store_image.dart';
import 'package:hackathon/view_model/store_image.dart';
import 'login_page.dart';
import 'event-detail-view.dart';

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
    final user_status = ref.watch(userStatusViewModelProvider.notifier);
    final isLoggedIn = ref.watch(userStatusViewModelProvider).isLoggedIn;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isLoggedIn == true && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('カレンダー'),
        actions: [
          IconButton(
            icon: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: const Icon(Icons.person, size: 26, color: Colors.black),
            ),
            onPressed: () {
              if (user_status.isLoggedIn == true) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('ログイン中'),
                      content: const Text('すでにログインしています'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('閉じる'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
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
                  bottom: -4,
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
                    return GestureDetector(
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
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                            Image.network(
                              item.imageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(item.description),
                                  const SizedBox(height: 4),
                                  Text('店舗名: ${item.storeName}'),
                                ],
                              ),
                            ),
                          ],
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
