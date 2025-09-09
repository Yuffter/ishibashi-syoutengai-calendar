import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../widget/store_image_form_modal.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TableCalendarSample(),
    );
  }
}

class TableCalendarSample extends StatefulWidget {
  const TableCalendarSample({super.key});

  @override
  State<TableCalendarSample> createState() => _TableCalendarSampleState();
}

class _TableCalendarSampleState extends State<TableCalendarSample> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(
                Icons.person,
                size: 26,
                color: Colors.black,
              ),
            ),
            // onPressed: () {
            //   // TODO: Add action
            //   showStoreImageFormModal(context);
            // },
            onPressed: () {
              showStoreImageFormModal(context);
              // showModalBottomSheet(
              //   context: context,
              //   isScrollControlled: true,
              //   builder: (_) => Container(
              //     height: 300,
              //     color: Colors.white,
              //     child: const Center(
              //       child: Text('テスト用のモーダル'),
              //     ),
              //   ),
              // );
            },
          ),
        ],
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2010, 1, 1),
        lastDay: DateTime.utc(2030, 1, 1),
        focusedDay: _focusedDay,
        locale: 'ja_JP',
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
      ),
    );
  }
}