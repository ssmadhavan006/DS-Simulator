import 'package:flutter/material.dart';

/// Sorting Visualizer Widget using CustomPainter
class SortingVisualizer extends StatelessWidget {
  final List<int> numbers;
  final List<int> comparingIndices;
  final List<int> swappingIndices;
  final List<int> sortedIndices;

  const SortingVisualizer({
    super.key,
    required this.numbers,
    this.comparingIndices = const [],
    this.swappingIndices = const [],
    this.sortedIndices = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomPaint(
      painter: _SortingPainter(
        numbers: numbers,
        comparingIndices: comparingIndices,
        swappingIndices: swappingIndices,
        sortedIndices: sortedIndices,
        backgroundColor: theme.scaffoldBackgroundColor,
        defaultColor: theme.colorScheme.primary,
        comparingColor: Colors.amber,
        swappingColor: Colors.red,
        sortedColor: Colors.green,
      ),
      size: Size.infinite,
    );
  }
}

class _SortingPainter extends CustomPainter {
  final List<int> numbers;
  final List<int> comparingIndices;
  final List<int> swappingIndices;
  final List<int> sortedIndices;
  final Color backgroundColor;
  final Color defaultColor;
  final Color comparingColor;
  final Color swappingColor;
  final Color sortedColor;

  _SortingPainter({
    required this.numbers,
    required this.comparingIndices,
    required this.swappingIndices,
    required this.sortedIndices,
    required this.backgroundColor,
    required this.defaultColor,
    required this.comparingColor,
    required this.swappingColor,
    required this.sortedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (numbers.isEmpty) return;

    final n = numbers.length;
    final maxValue = numbers.reduce((a, b) => a > b ? a : b);

    // Calculate bar dimensions
    final barWidth = (size.width - (n + 1) * 2) / n;
    final maxHeight = size.height - 40;

    for (int i = 0; i < n; i++) {
      final barHeight = (numbers[i] / maxValue) * maxHeight;
      final x = 2 + i * (barWidth + 2);
      final y = size.height - barHeight - 20;

      // Determine bar color
      Color color;
      if (swappingIndices.contains(i)) {
        color = swappingColor;
      } else if (comparingIndices.contains(i)) {
        color = comparingColor;
      } else if (sortedIndices.contains(i)) {
        color = sortedColor;
      } else {
        color = defaultColor;
      }

      // Draw bar
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(2),
      );

      canvas.drawRRect(rect, paint);

      // Draw value label (only if bars are wide enough)
      if (barWidth > 20) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${numbers[i]}',
            style: TextStyle(
              color: Colors.white,
              fontSize: barWidth > 30 ? 10 : 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(x + (barWidth - textPainter.width) / 2, y + 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SortingPainter oldDelegate) {
    return numbers != oldDelegate.numbers ||
        comparingIndices != oldDelegate.comparingIndices ||
        swappingIndices != oldDelegate.swappingIndices ||
        sortedIndices != oldDelegate.sortedIndices;
  }
}
