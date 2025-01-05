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
    return SizedBox(
      width: 160,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '일정',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<CalendarFormat>(
                    isDense: true,
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
              availableGestures: AvailableGestures.none,
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
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: Colors.red, fontSize: 11),
                defaultTextStyle: TextStyle(fontSize: 11),
                selectedTextStyle: TextStyle(fontSize: 11, color: Colors.white),
                todayTextStyle: TextStyle(fontSize: 11),
                cellMargin: EdgeInsets.zero,
                cellPadding: EdgeInsets.all(1),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 12),
                leftChevronIcon: Icon(Icons.chevron_left, size: 14),
                rightChevronIcon: Icon(Icons.chevron_right, size: 14),
                headerPadding: EdgeInsets.symmetric(vertical: 2),
              ),
              weekendDays: [DateTime.saturday, DateTime.sunday],
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 10),
                weekendStyle: TextStyle(fontSize: 10, color: Colors.red),
              ),
              daysOfWeekHeight: 16,
              rowHeight: 18,
            ),
          ],
        ),
      ),
    );
  }
} 