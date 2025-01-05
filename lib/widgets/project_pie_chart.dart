import 'package:flutter/material.dart';

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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('[분류]', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        SizedBox(
          height: 80,
          width: 80,
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
                        fontSize: 11,
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
        ),
        SizedBox(height: 4),
        if (categoryStats.isNotEmpty)
          ...categoryStats.entries.map((entry) {
            final index = categoryStats.keys.toList().indexOf(entry.key);
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    color: colors[index % colors.length],
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${entry.key} ${entry.value}',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
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