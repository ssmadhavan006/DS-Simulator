import 'package:flutter/material.dart';
import '../../models/tree_node.dart';
import '../../utils/constants.dart';

/// Tree Visualizer Widget using CustomPainter for BST/AVL
class TreeVisualizer extends StatefulWidget {
  final TreeNode? root;
  final TreeNode? animatingNode;
  final List<TreeNode> animatingPath;
  final bool showBalanceFactor; // For AVL mode

  const TreeVisualizer({
    super.key,
    this.root,
    this.animatingNode,
    this.animatingPath = const [],
    this.showBalanceFactor = false,
  });

  @override
  State<TreeVisualizer> createState() => _TreeVisualizerState();
}

class _TreeVisualizerState extends State<TreeVisualizer>
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
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(TreeVisualizer oldWidget) {
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

    if (widget.root == null) {
      return Center(
        child: Text(
          'Tree is empty\nInsert values to begin',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withAlpha(127),
            fontSize: 16,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _TreePainter(
            root: widget.root!,
            animatingNode: widget.animatingNode,
            animatingPath: widget.animatingPath,
            animationValue: _animation.value,
            isDark: isDark,
            primaryColor: theme.colorScheme.primary,
            secondaryColor: AppConstants.secondaryColor,
            showBalanceFactor: widget.showBalanceFactor,
          ),
        );
      },
    );
  }
}

class _TreePainter extends CustomPainter {
  final TreeNode root;
  final TreeNode? animatingNode;
  final List<TreeNode> animatingPath;
  final double animationValue;
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;
  final bool showBalanceFactor;

  _TreePainter({
    required this.root,
    this.animatingNode,
    required this.animatingPath,
    required this.animationValue,
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
    this.showBalanceFactor = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodeRadius = 25.0;
    final levelHeight = 80.0;

    // Calculate positions for all nodes
    _calculatePositions(root, size.width / 2, 50, size.width / 4, levelHeight);

    // Draw edges first (so they appear behind nodes)
    _drawEdges(canvas, root, nodeRadius);

    // Draw nodes
    _drawNodes(canvas, root, nodeRadius);
  }

  void _calculatePositions(
    TreeNode node,
    double x,
    double y,
    double horizontalSpacing,
    double verticalSpacing,
  ) {
    node.x = x;
    node.y = y;

    if (node.left != null) {
      _calculatePositions(
        node.left!,
        x - horizontalSpacing,
        y + verticalSpacing,
        horizontalSpacing / 2,
        verticalSpacing,
      );
    }

    if (node.right != null) {
      _calculatePositions(
        node.right!,
        x + horizontalSpacing,
        y + verticalSpacing,
        horizontalSpacing / 2,
        verticalSpacing,
      );
    }
  }

  void _drawEdges(Canvas canvas, TreeNode node, double nodeRadius) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withAlpha(127)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (node.left != null) {
      // Check if edge is in animating path
      bool isInPath =
          animatingPath.contains(node) && animatingPath.contains(node.left!);

      if (isInPath) {
        paint.color = secondaryColor;
        paint.strokeWidth = 3;
      }

      canvas.drawLine(
        Offset(node.x, node.y + nodeRadius),
        Offset(node.left!.x, node.left!.y - nodeRadius),
        paint,
      );

      _drawEdges(canvas, node.left!, nodeRadius);

      // Reset paint
      paint.color = (isDark ? Colors.white : Colors.black).withAlpha(127);
      paint.strokeWidth = 2;
    }

    if (node.right != null) {
      bool isInPath =
          animatingPath.contains(node) && animatingPath.contains(node.right!);

      if (isInPath) {
        paint.color = secondaryColor;
        paint.strokeWidth = 3;
      }

      canvas.drawLine(
        Offset(node.x, node.y + nodeRadius),
        Offset(node.right!.x, node.right!.y - nodeRadius),
        paint,
      );

      _drawEdges(canvas, node.right!, nodeRadius);
    }
  }

  void _drawNodes(Canvas canvas, TreeNode node, double radius) {
    final isAnimating = node.id == animatingNode?.id;
    final isInPath = animatingPath.contains(node);

    // Determine node color
    Color nodeColor = primaryColor;
    if (isAnimating) {
      nodeColor = secondaryColor;
    } else if (isInPath) {
      nodeColor = secondaryColor.withAlpha(179);
    }

    // Scale animation for newly inserted node
    double scale = 1.0;
    if (isAnimating) {
      scale = animationValue;
    }

    // Draw circle
    final circlePaint = Paint()
      ..color = nodeColor.withAlpha((scale * 230).round())
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(node.x, node.y), radius * scale, circlePaint);

    // Draw border
    final borderPaint = Paint()
      ..color = nodeColor.withAlpha((scale * 255).round())
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(node.x, node.y), radius * scale, borderPaint);

    // Glow effect for animating node
    if (isAnimating) {
      final glowPaint = Paint()
        ..color = secondaryColor.withAlpha(51)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(node.x, node.y), radius * scale, glowPaint);
    }

    // Draw value text
    final textPainter = TextPainter(
      text: TextSpan(
        text: node.value.toString(),
        style: TextStyle(
          color: Colors.white.withAlpha((scale * 255).round()),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(node.x - textPainter.width / 2, node.y - textPainter.height / 2),
    );

    // Draw balance factor badge (for AVL)
    if (showBalanceFactor) {
      final bf = node.balanceFactor;
      final bfColor = bf.abs() > 1
          ? Colors.red
          : (bf == 0 ? Colors.green : Colors.orange);

      final badgePainter = TextPainter(
        text: TextSpan(
          text: bf >= 0 ? '+$bf' : '$bf',
          style: TextStyle(
            color: bfColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      badgePainter.paint(
        canvas,
        Offset(node.x + radius * 0.6, node.y - radius - 8),
      );
    }

    // Recursively draw children
    if (node.left != null) _drawNodes(canvas, node.left!, radius);
    if (node.right != null) _drawNodes(canvas, node.right!, radius);
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) {
    return root != oldDelegate.root ||
        animatingNode != oldDelegate.animatingNode ||
        animationValue != oldDelegate.animationValue ||
        animatingPath != oldDelegate.animatingPath;
  }
}
