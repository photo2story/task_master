import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '일정',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                DropdownButton<CalendarFormat>(
                  value: _calendarFormat,
                  items: [
                    DropdownMenuItem(
                      value: CalendarFormat.month,
                      child: Text('월'),
                    ),
                    DropdownMenuItem(
                      value: CalendarFormat.week,
                      child: Text('주'),
                    ),
                    DropdownMenuItem(
                      value: CalendarFormat.twoWeeks,
                      child: Text('2주'),
                    ),
                  ],
                  onChanged: (format) {
                    if (format != null) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            // 캘린더 스타일 설정
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red),
            ),
            // 헤더 스타일 설정
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            // 주말 표시
            weekendDays: [DateTime.saturday, DateTime.sunday],
            // 한글 요일 표시
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.black),
              weekendStyle: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
} 