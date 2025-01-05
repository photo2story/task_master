import 'package:flutter/material.dart';

class QuickInputWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '빠른 입력',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '새 할일',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 