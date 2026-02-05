import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/node.dart';
import '../../utils/constants.dart';

/// Queue Visualizer Widget using CustomPainter
class QueueVisualizer extends StatefulWidget {
  final List<Node> items;
  final Node? animatingNode;
  final String? currentOperation;
  final bool isCircular;
  final int maxSize;

  const QueueVisualizer({
    super.key,
    required this.items,
    this.animatingNode,
    this.currentOperation,
    this.isCircular = false,
    this.maxSize = 20,
  });

  @override
  State<QueueVisualizer> createState() => _QueueVisualizerState();
}

class _QueueVisualizerState extends State<QueueVisualizer>
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
  void didUpdateWidget(QueueVisualizer oldWidget) {
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
            if (widget.isCircular) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _CircularQueuePainter(
                  items: widget.items,
                  animatingNode: widget.animatingNode,
                  currentOperation: widget.currentOperation,
                  animationValue: _animation.value,
                  isDark: isDark,
                  primaryColor: theme.colorScheme.primary,
                  secondaryColor: AppConstants.secondaryColor,
                  errorColor: AppConstants.errorColor,
                  maxSize: widget.maxSize,
                ),
              );
            } else {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _LinearQueuePainter(
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
            }
          },
        );
      },
    );
  }
}

/// Linear Queue Painter
class _LinearQueuePainter extends CustomPainter {
  final List<Node> items;
  final Node? animatingNode;
  final String? currentOperation;
  final double animationValue;
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;
  final Color errorColor;

  _LinearQueuePainter({
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
    final nodeWidth = 60.0;
    final nodeHeight = 50.0;
    final spacing = 8.0;
    final centerY = size.height / 2;

    // Calculate total width and start position
    final totalWidth = items.length * (nodeWidth + spacing);
    final startX = (size.width - totalWidth) / 2;

    // Draw container
    _drawQueueContainer(
      canvas,
      size,
      startX,
      centerY,
      nodeWidth,
      nodeHeight,
      spacing,
    );

    // Draw nodes from front to rear (left to right)
    for (int i = 0; i < items.length; i++) {
      final node = items[i];
      final isAnimating = node.id == animatingNode?.id;
      final isFront = i == 0;
      final isRear = i == items.length - 1;

      double xPos = startX + i * (nodeWidth + spacing);
      double opacity = 1.0;
      double scale = 1.0;

      // Animation for enqueue (new item at rear)
      if (isAnimating && currentOperation == 'enqueue') {
        scale = animationValue;
        opacity = animationValue;
        xPos = startX + i * (nodeWidth + spacing) + (1 - animationValue) * 50;
      }

      // Animation for dequeue (remove from front)
      if (isAnimating && currentOperation == 'dequeue') {
        scale = 1 - animationValue * 0.3;
        opacity = 1 - animationValue;
        xPos = startX + i * (nodeWidth + spacing) - animationValue * 80;
      }

      // Highlight for peek
      final isPeeking = isAnimating && currentOperation == 'peek';

      _drawNode(
        canvas,
        xPos,
        centerY - (nodeHeight * scale) / 2,
        nodeWidth * scale,
        nodeHeight * scale,
        node.value.toString(),
        isFront: isFront,
        isRear: isRear,
        isPeeking: isPeeking,
        opacity: opacity,
      );
    }

    // Draw Front/Rear pointers
    if (items.isNotEmpty) {
      final frontX = startX + nodeWidth / 2;
      final rearX =
          startX + (items.length - 1) * (nodeWidth + spacing) + nodeWidth / 2;
      _drawPointers(canvas, frontX, rearX, centerY, nodeHeight);
    }

    // Draw empty queue message
    if (items.isEmpty) {
      _drawEmptyMessage(canvas, size);
    }
  }

  void _drawQueueContainer(
    Canvas canvas,
    Size size,
    double startX,
    double centerY,
    double nodeWidth,
    double nodeHeight,
    double spacing,
  ) {
    final containerWidth = 10 * (nodeWidth + spacing) + 20;
    final containerX = (size.width - containerWidth) / 2;

    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withAlpha(25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw container box
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        containerX,
        centerY - nodeHeight / 2 - 15,
        containerWidth,
        nodeHeight + 30,
      ),
      const Radius.circular(10),
    );

    canvas.drawRRect(rect, paint);

    // Left arrow (FRONT)
    _drawArrowMarker(canvas, containerX - 30, centerY, 'FRONT', true);

    // Right arrow (REAR)
    _drawArrowMarker(
      canvas,
      containerX + containerWidth + 30,
      centerY,
      'REAR',
      false,
    );
  }

  void _drawArrowMarker(
    Canvas canvas,
    double x,
    double y,
    String label,
    bool leftPointing,
  ) {
    final paint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    // Arrow
    final path = Path();
    if (leftPointing) {
      path
        ..moveTo(x + 20, y)
        ..lineTo(x + 5, y - 8)
        ..lineTo(x + 5, y + 8)
        ..close();
    } else {
      path
        ..moveTo(x - 20, y)
        ..lineTo(x - 5, y - 8)
        ..lineTo(x - 5, y + 8)
        ..close();
    }

    canvas.drawPath(path, paint);

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: secondaryColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textX = leftPointing ? x - 10 : x - textPainter.width + 10;
    textPainter.paint(canvas, Offset(textX, y + 15));
  }

  void _drawNode(
    Canvas canvas,
    double x,
    double y,
    double width,
    double height,
    String value, {
    bool isFront = false,
    bool isRear = false,
    bool isPeeking = false,
    double opacity = 1.0,
  }) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, width, height),
      const Radius.circular(10),
    );

    // Node color
    Color nodeColor = primaryColor;
    if (isFront) nodeColor = secondaryColor;
    if (isRear && !isFront) nodeColor = primaryColor;
    if (isPeeking) nodeColor = secondaryColor;

    final paint = Paint()
      ..color = nodeColor.withAlpha((opacity * 230).round())
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
          fontSize: 16,
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

  void _drawPointers(
    Canvas canvas,
    double frontX,
    double rearX,
    double centerY,
    double nodeHeight,
  ) {
    // Front pointer (pointing down from above)
    _drawVerticalPointer(
      canvas,
      frontX,
      centerY - nodeHeight / 2 - 30,
      'F',
      true,
    );

    // Rear pointer (pointing up from below)
    if ((rearX - frontX).abs() > 10) {
      _drawVerticalPointer(
        canvas,
        rearX,
        centerY + nodeHeight / 2 + 30,
        'R',
        false,
      );
    }
  }

  void _drawVerticalPointer(
    Canvas canvas,
    double x,
    double y,
    String label,
    bool pointingDown,
  ) {
    final paint = Paint()
      ..color = pointingDown ? secondaryColor : primaryColor
      ..style = PaintingStyle.fill;

    // Arrow
    final path = Path();
    if (pointingDown) {
      path
        ..moveTo(x, y + 15)
        ..lineTo(x - 6, y)
        ..lineTo(x + 6, y)
        ..close();
    } else {
      path
        ..moveTo(x, y - 15)
        ..lineTo(x - 6, y)
        ..lineTo(x + 6, y)
        ..close();
    }

    canvas.drawPath(path, paint);

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: pointingDown ? secondaryColor : primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textY = pointingDown ? y - 20 : y + 5;
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, textY));
  }

  void _drawEmptyMessage(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Queue is empty\nEnqueue values to begin',
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
  bool shouldRepaint(covariant _LinearQueuePainter oldDelegate) {
    return items != oldDelegate.items ||
        animatingNode != oldDelegate.animatingNode ||
        animationValue != oldDelegate.animationValue ||
        currentOperation != oldDelegate.currentOperation;
  }
}

/// Circular Queue Painter
class _CircularQueuePainter extends CustomPainter {
  final List<Node> items;
  final Node? animatingNode;
  final String? currentOperation;
  final double animationValue;
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;
  final Color errorColor;
  final int maxSize;

  _CircularQueuePainter({
    required this.items,
    this.animatingNode,
    this.currentOperation,
    required this.animationValue,
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
    required this.errorColor,
    required this.maxSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(size.width, size.height) / 2 - 60;
    final nodeRadius = 25.0;
    final displaySlots = math.min(12, maxSize); // Show up to 12 slots

    // Draw circular container
    _drawCircularContainer(canvas, centerX, centerY, radius, displaySlots);

    // Draw nodes
    for (int i = 0; i < items.length && i < displaySlots; i++) {
      final node = items[i];
      final isAnimating = node.id == animatingNode?.id;
      final isFront = i == 0;
      final isRear = i == items.length - 1;

      final angle = (2 * math.pi * i / displaySlots) - math.pi / 2;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);

      double opacity = 1.0;
      double scale = 1.0;

      if (isAnimating && currentOperation == 'enqueue') {
        scale = animationValue;
        opacity = animationValue;
      }

      if (isAnimating && currentOperation == 'dequeue') {
        scale = 1 - animationValue * 0.3;
        opacity = 1 - animationValue;
      }

      final isPeeking = isAnimating && currentOperation == 'peek';

      _drawCircularNode(
        canvas,
        x,
        y,
        nodeRadius * scale,
        node.value.toString(),
        isFront: isFront,
        isRear: isRear,
        isPeeking: isPeeking,
        opacity: opacity,
      );

      // Draw Front/Rear labels
      if (isFront) {
        _drawNodeLabel(
          canvas,
          x,
          y,
          nodeRadius + 20,
          angle,
          'F',
          secondaryColor,
        );
      }
      if (isRear && !isFront) {
        _drawNodeLabel(canvas, x, y, nodeRadius + 20, angle, 'R', primaryColor);
      }
    }

    // Draw empty slots
    for (int i = items.length; i < displaySlots; i++) {
      final angle = (2 * math.pi * i / displaySlots) - math.pi / 2;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      _drawEmptySlot(canvas, x, y, nodeRadius);
    }

    // Draw center info
    _drawCenterInfo(canvas, centerX, centerY);
  }

  void _drawCircularContainer(
    Canvas canvas,
    double centerX,
    double centerY,
    double radius,
    int slots,
  ) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withAlpha(25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(centerX, centerY), radius + 35, paint);
    canvas.drawCircle(
      Offset(centerX, centerY),
      radius - 35,
      Paint()
        ..color = (isDark ? Colors.white : Colors.black).withAlpha(12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawCircularNode(
    Canvas canvas,
    double x,
    double y,
    double radius,
    String value, {
    bool isFront = false,
    bool isRear = false,
    bool isPeeking = false,
    double opacity = 1.0,
  }) {
    Color nodeColor = primaryColor;
    if (isFront) nodeColor = secondaryColor;
    if (isPeeking) nodeColor = secondaryColor;

    final paint = Paint()
      ..color = nodeColor.withAlpha((opacity * 230).round())
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), radius, paint);

    // Border
    final borderPaint = Paint()
      ..color = nodeColor.withAlpha((opacity * 200).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(x, y), radius, borderPaint);

    // Glow effect
    if (isPeeking) {
      final glowPaint = Paint()
        ..color = secondaryColor.withAlpha(51)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(x, y), radius, glowPaint);
    }

    // Value text
    final textPainter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: Colors.white.withAlpha((opacity * 255).round()),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  void _drawEmptySlot(Canvas canvas, double x, double y, double radius) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withAlpha(38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Draw dashed circle
    canvas.drawCircle(Offset(x, y), radius, paint);
  }

  void _drawNodeLabel(
    Canvas canvas,
    double x,
    double y,
    double offset,
    double angle,
    String label,
    Color color,
  ) {
    final labelX = x + offset * math.cos(angle) * 0.3;
    final labelY = y + offset * math.sin(angle) * 0.3;

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Background
    canvas.drawCircle(
      Offset(labelX, labelY),
      10,
      Paint()..color = color.withAlpha(51),
    );

    textPainter.paint(
      canvas,
      Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2),
    );
  }

  void _drawCenterInfo(Canvas canvas, double centerX, double centerY) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: items.isEmpty ? 'Empty\nCircular Queue' : '${items.length} items',
        style: TextStyle(
          color: (isDark ? Colors.white : Colors.black).withAlpha(127),
          fontSize: items.isEmpty ? 14 : 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2, centerY - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _CircularQueuePainter oldDelegate) {
    return items != oldDelegate.items ||
        animatingNode != oldDelegate.animatingNode ||
        animationValue != oldDelegate.animationValue ||
        currentOperation != oldDelegate.currentOperation;
  }
}
