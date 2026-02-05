import 'package:flutter/material.dart';
import '../../models/node.dart';
import '../../utils/constants.dart';

/// Stack Visualizer Widget using CustomPainter
class StackVisualizer extends StatefulWidget {
  final List<Node> items;
  final Node? animatingNode;
  final String? currentOperation;

  const StackVisualizer({
    super.key,
    required this.items,
    this.animatingNode,
    this.currentOperation,
  });

  @override
  State<StackVisualizer> createState() => _StackVisualizerState();
}

class _StackVisualizerState extends State<StackVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.animationNormal,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void didUpdateWidget(StackVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animatingNode != null &&
        widget.animatingNode != oldWidget.animatingNode) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _StackPainter(
                items: widget.items,
                animatingNode: widget.animatingNode,
                currentOperation: widget.currentOperation,
                animationValue: _animation.value,
                isDark: isDark,
                primaryColor: theme.colorScheme.primary,
                secondaryColor: AppConstants.secondaryColor,
                errorColor: AppConstants.errorColor,
              ),
            );
          },
        );
      },
    );
  }
}

class _StackPainter extends CustomPainter {
  final List<Node> items;
  final Node? animatingNode;
  final String? currentOperation;
  final double animationValue;
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;
  final Color errorColor;

  _StackPainter({
    required this.items,
    this.animatingNode,
    this.currentOperation,
    required this.animationValue,
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
    required this.errorColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodeWidth = 80.0;
    final nodeHeight = 50.0;
    final spacing = 8.0;
    final startX = (size.width - nodeWidth) / 2;
    final startY = size.height - 80; // Bottom padding

    // Draw container outline
    _drawStackContainer(
      canvas,
      size,
      startX,
      startY,
      nodeWidth,
      items.length,
      nodeHeight,
      spacing,
    );

    // Draw nodes from bottom to top
    for (int i = 0; i < items.length; i++) {
      final node = items[i];
      final isAnimating = node.id == animatingNode?.id;
      final isTop = i == items.length - 1;

      double yPos = startY - (i + 1) * (nodeHeight + spacing);
      double opacity = 1.0;
      double scale = 1.0;

      // Animation for push
      if (isAnimating && currentOperation == 'push') {
        scale = animationValue;
        opacity = animationValue;
        yPos =
            startY -
            (i + 1) * (nodeHeight + spacing) -
            (1 - animationValue) * 50;
      }

      // Animation for pop
      if (isAnimating && currentOperation == 'pop') {
        scale = 1 - animationValue * 0.3;
        opacity = 1 - animationValue;
        yPos = startY - (i + 1) * (nodeHeight + spacing) - animationValue * 80;
      }

      // Highlight for peek
      final isPeeking = isAnimating && currentOperation == 'peek';

      _drawNode(
        canvas,
        startX + (nodeWidth * (1 - scale)) / 2,
        yPos,
        nodeWidth * scale,
        nodeHeight * scale,
        node.value.toString(),
        isTop: isTop,
        isPeeking: isPeeking,
        opacity: opacity,
      );
    }

    // Draw "TOP" pointer
    if (items.isNotEmpty) {
      final topY = startY - items.length * (nodeHeight + spacing);
      _drawTopPointer(
        canvas,
        startX + nodeWidth + 20,
        topY + nodeHeight / 2,
        size,
      );
    }

    // Draw empty stack message
    if (items.isEmpty) {
      _drawEmptyMessage(canvas, size);
    }
  }

  void _drawStackContainer(
    Canvas canvas,
    Size size,
    double startX,
    double startY,
    double nodeWidth,
    int itemCount,
    double nodeHeight,
    double spacing,
  ) {
    final containerHeight =
        (AppConstants.maxStackSize / 2).ceil() * (nodeHeight + spacing) + 40;
    final containerTop = startY - containerHeight;

    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withAlpha(25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw container (3 sides - no top)
    final path = Path()
      ..moveTo(startX - 10, containerTop)
      ..lineTo(startX - 10, startY + 10)
      ..lineTo(startX + nodeWidth + 10, startY + 10)
      ..lineTo(startX + nodeWidth + 10, containerTop);

    canvas.drawPath(path, paint);

    // Draw base line label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'BOTTOM',
        style: TextStyle(
          color: (isDark ? Colors.white : Colors.black).withAlpha(127),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(startX + (nodeWidth - textPainter.width) / 2, startY + 15),
    );
  }

  void _drawNode(
    Canvas canvas,
    double x,
    double y,
    double width,
    double height,
    String value, {
    bool isTop = false,
    bool isPeeking = false,
    double opacity = 1.0,
  }) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, width, height),
      const Radius.circular(10),
    );

    // Gradient fill
    Color nodeColor = isTop ? primaryColor : primaryColor.withAlpha(179);
    if (isPeeking) {
      nodeColor = secondaryColor;
    }

    final paint = Paint()
      ..color = nodeColor.withAlpha((opacity * 255).round())
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rect, paint);

    // Border
    final borderPaint = Paint()
      ..color = nodeColor.withAlpha((opacity * 200).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(rect, borderPaint);

    // Glow effect for animating/peeking nodes
    if (isPeeking) {
      final glowPaint = Paint()
        ..color = secondaryColor.withAlpha(51)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawRRect(rect, glowPaint);
    }

    // Value text
    final textPainter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: Colors.white.withAlpha((opacity * 255).round()),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        x + (width - textPainter.width) / 2,
        y + (height - textPainter.height) / 2,
      ),
    );
  }

  void _drawTopPointer(Canvas canvas, double x, double y, Size size) {
    final paint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    // Arrow
    final path = Path()
      ..moveTo(x, y)
      ..lineTo(x + 15, y - 8)
      ..lineTo(x + 15, y + 8)
      ..close();

    canvas.drawPath(path, paint);

    // Line
    canvas.drawLine(
      Offset(x + 15, y),
      Offset(x + 50, y),
      Paint()
        ..color = secondaryColor
        ..strokeWidth = 2,
    );

    // "TOP" label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'TOP',
        style: TextStyle(
          color: secondaryColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(x + 55, y - textPainter.height / 2));
  }

  void _drawEmptyMessage(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Stack is empty\nPush values to begin',
        style: TextStyle(
          color: (isDark ? Colors.white : Colors.black).withAlpha(127),
          fontSize: 16,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _StackPainter oldDelegate) {
    return items != oldDelegate.items ||
        animatingNode != oldDelegate.animatingNode ||
        animationValue != oldDelegate.animationValue ||
        currentOperation != oldDelegate.currentOperation;
  }
}
