import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectProgressIndicator extends StatelessWidget {
  final List<Project> projects;

  const ProjectProgressIndicator({
    Key? key,
    required this.projects,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) return SizedBox();

    final completedCount = projects.where((p) => 
      p.status == '완료' || p.status == '보류'
    ).length;
    final progress = completedCount / projects.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.green[700]!
                        : Colors.green[300]!,
                  ),
                  minHeight: 8,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        SizedBox(height: 2),
        Text(
          '완료/보류: $completedCount / 전체: ${projects.length}',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
} 