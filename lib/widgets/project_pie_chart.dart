import 'package:flutter/material.dart';
import 'dart:math';

class ProjectPieChart extends StatelessWidget {
  final Map<String, int> categoryStats;

  const ProjectPieChart({
    Key? key,
    required this.categoryStats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue[200],
      Colors.green[200],
      Colors.orange[200],
      Colors.purple[200],
      Colors.red[200],
      Colors.teal[200],
    ];

    return SizedBox(
      height: 100,
      width: 100,
      child: categoryStats.isEmpty
          ? Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: _EmptyPieChartPainter(color: Colors.grey[200]!),
                ),
                Text(
                  'No Plan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          : CustomPaint(
              size: Size.infinite,
              painter: _PieChartPainter(
                categories: categoryStats.entries.toList(),
                colors: colors,
              ),
            ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> categories;
  final List<Color?> colors;

  _PieChartPainter({required this.categories, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = categories.fold<int>(0, (sum, item) => sum + item.value);
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    
    double startAngle = -90 * (3.141592 / 180);
    
    for (var i = 0; i < categories.length; i++) {
      final sweepAngle = (categories[i].value / total) * 2 * 3.141592;
      final paint = Paint()
        ..color = colors[i % colors.length]!
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      final textAngle = startAngle + (sweepAngle / 2);
      final textRadius = radius * 0.6;
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${categories[i].key}\n${categories[i].value}',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      
      textPainter.layout(
        maxWidth: radius,
      );
      textPainter.paint(
        canvas,
        Offset(
          textX - (textPainter.width / 2),
          textY - (textPainter.height / 2),
        ),
      );
      
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _EmptyPieChartPainter extends CustomPainter {
  final Color color;

  _EmptyPieChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 