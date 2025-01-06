import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime? selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime) onDateChanged;
  final String label;
  final bool isStartDate;

  const CalendarWidget({
    super.key,
    this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
    required this.label,
    this.isStartDate = false,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _currentMonth;
  late ValueNotifier<DateTime> _displayedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.selectedDate ?? DateTime.now();
    _displayedDate = ValueNotifier(_currentMonth);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _displayedDate.value = _currentMonth;
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _displayedDate.value = _currentMonth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더 (년월 표시 및 이동 버튼)
              ValueListenableBuilder<DateTime>(
                valueListenable: _displayedDate,
                builder: (context, currentDate, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left, size: 16),
                            onPressed: _previousMonth,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          IconButton(
                            icon: Icon(Icons.chevron_right, size: 16),
                            onPressed: _nextMonth,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              Divider(),
              // 요일 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['일', '월', '화', '수', '목', '금', '토']
                    .map((day) => SizedBox(
                          width: 24,
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: 4),
              // 달력 그리드
              ...List.generate(6, (weekIndex) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (dayIndex) {
                    final date = _getDate(weekIndex, dayIndex);
                    final isSelected = widget.selectedDate != null &&
                        date.year == widget.selectedDate!.year &&
                        date.month == widget.selectedDate!.month &&
                        date.day == widget.selectedDate!.day;
                    final isThisMonth = date.month == _currentMonth.month;

                    return SizedBox(
                      width: 24,
                      height: 24,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: isSelected ? Colors.blue : null,
                          foregroundColor: !isThisMonth
                              ? Colors.grey
                              : isSelected
                                  ? Colors.white
                                  : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (date.isBefore(widget.firstDate) ||
                              date.isAfter(widget.lastDate)) {
                            return;
                          }
                          widget.onDateChanged(date);
                        },
                        child: Text(
                          '${date.day}',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    );
                  }),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _getDate(int weekIndex, int dayIndex) {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final date = firstDayOfMonth
        .subtract(Duration(days: firstWeekday))
        .add(Duration(days: weekIndex * 7 + dayIndex));
    return date;
  }

  @override
  void dispose() {
    _displayedDate.dispose();
    super.dispose();
  }
} 