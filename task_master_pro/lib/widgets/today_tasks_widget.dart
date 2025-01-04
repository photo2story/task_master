import 'package:flutter/material.dart';

class TodayTasksWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '오늘의 할일',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: Center(
              child: Text('오늘 할일이 없습니다.'),
            ),
          ),
        ],
      ),
    );
  }
} 