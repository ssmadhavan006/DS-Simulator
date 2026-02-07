import 'package:flutter/material.dart';
import '../../models/graph_model.dart';
import '../../providers/graph_provider.dart';
import '../../utils/constants.dart';

/// Graph Visualizer with interactive canvas
class GraphVisualizer extends StatefulWidget {
  final GraphModel graph;
  final Map<GraphNode, NodeState> nodeStates;
  final GraphNode? currentNode;
  final GraphNode? selectedNode;
  final GraphNode? edgeSourceNode;
  final Function(GraphNode, Offset) onNodeDragged;
  final Function(GraphNode)? onNodeTapped;

  const GraphVisualizer({
    super.key,
    required this.graph,
    required this.nodeStates,
    this.currentNode,
    this.selectedNode,
    this.edgeSourceNode,
    required this.onNodeDragged,
    this.onNodeTapped,
  });

  @override
  State<GraphVisualizer> createState() => _GraphVisualizerState();
}

class _GraphVisualizerState extends State<GraphVisualizer>
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
    _controller.repeat(reverse: true);
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

    if (widget.graph.nodeCount == 0) {
      return Center(
        child: Text(
          'Graph is empty\nAdd nodes to begin',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withAlpha(127),
            fontSize: 16,
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _GraphPainter(
              graph: widget.graph,
              nodeStates: widget.nodeStates,
              currentNode: widget.currentNode,
              selectedNode: widget.selectedNode,
              edgeSourceNode: widget.edgeSourceNode,
              animationValue: _animation.value,
              isDark: isDark,
              primaryColor: theme.colorScheme.primary,
              secondaryColor: AppConstants.secondaryColor,
            ),
            child: Stack(
              children: widget.graph.nodes.map((node) {
                return _DraggableNode(
                  node: node,
                  onDragged: widget.onNodeDragged,
                  onTapped: widget.onNodeTapped,
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

/// Draggable node widget
class _DraggableNode extends StatelessWidget {
  final GraphNode node;
  final Function(GraphNode, Offset) onDragged;
  final Function(GraphNode)? onTapped;

  const _DraggableNode({
    required this.node,
    required this.onDragged,
    this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: node.position.dx - 25,
      top: node.position.dy - 25,
      child: GestureDetector(
        onTap: () => onTapped?.call(node),
        onPanUpdate: (details) {
          onDragged(node, node.position + details.delta);
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(color: Colors.transparent),
        ),
      ),
    );
  }
}

/// Custom painter for graph
class _GraphPainter extends CustomPainter {
  final GraphModel graph;
  final Map<GraphNode, NodeState> nodeStates;
  final GraphNode? currentNode;
  final GraphNode? selectedNode;
  final GraphNode? edgeSourceNode;
  final double animationValue;
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;

  _GraphPainter({
    required this.graph,
    required this.nodeStates,
    this.currentNode,
    this.selectedNode,
    this.edgeSourceNode,
    required this.animationValue,
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw edges first
    _drawEdges(canvas);

    // Draw nodes on top
    _drawNodes(canvas);
  }

  void _drawEdges(Canvas canvas) {
    for (final edge in graph.edges) {
      final paint = Paint()
        ..color = (isDark ? Colors.white : Colors.black).withAlpha(102)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final start = edge.source.position;
      final end = edge.target.position;

      // Draw line
      canvas.drawLine(start, end, paint);

      // Draw arrow for directed graphs
      if (graph.isDirected) {
        _drawArrow(canvas, start, end, paint);
      }

      // Draw weight label (if needed)
      if (edge.weight != 1) {
        final midPoint = Offset(
          (start.dx + end.dx) / 2,
          (start.dy + end.dy) / 2,
        );

        final textPainter = TextPainter(
          text: TextSpan(
            text: edge.weight.toString(),
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(
            midPoint.dx - textPainter.width / 2,
            midPoint.dy - textPainter.height / 2,
          ),
        );
      }
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    const arrowSize = 10.0;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final angle = atan2(dy, dx);

    // Offset arrow to node edge (radius 25)
    final arrowEnd = Offset(end.dx - 25 * cos(angle), end.dy - 25 * sin(angle));

    final arrowPath = Path();
    arrowPath.moveTo(arrowEnd.dx, arrowEnd.dy);
    arrowPath.lineTo(
      arrowEnd.dx - arrowSize * cos(angle - 0.5),
      arrowEnd.dy - arrowSize * sin(angle - 0.5),
    );
    arrowPath.moveTo(arrowEnd.dx, arrowEnd.dy);
    arrowPath.lineTo(
      arrowEnd.dx - arrowSize * cos(angle + 0.5),
      arrowEnd.dy - arrowSize * sin(angle + 0.5),
    );

    canvas.drawPath(arrowPath, paint);
  }

  void _drawNodes(Canvas canvas) {
    for (final node in graph.nodes) {
      final radius = 25.0;
      final isCurrentNode = node == currentNode;
      final isSelected = node == selectedNode;
      final isEdgeSource = node == edgeSourceNode;

      // Determine node color based on state
      Color nodeColor = primaryColor;
      if (isEdgeSource) {
        nodeColor = Colors.orange;
      } else if (isCurrentNode) {
        nodeColor = secondaryColor;
      } else if (isSelected) {
        nodeColor = primaryColor.withAlpha(204);
      } else {
        final state = nodeStates[node] ?? NodeState.unvisited;
        switch (state) {
          case NodeState.unvisited:
            nodeColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
            break;
          case NodeState.visiting:
            nodeColor = Colors.orange;
            break;
          case NodeState.visited:
            nodeColor = secondaryColor;
            break;
        }
      }

      // Pulse effect for current node
      double scale = 1.0;
      if (isCurrentNode || isEdgeSource) {
        scale = 1.0 + (animationValue * 0.2);
      }

      // Draw circle
      final circlePaint = Paint()
        ..color = nodeColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(node.position, radius * scale, circlePaint);

      // Draw border
      final borderPaint = Paint()
        ..color = nodeColor.withAlpha(255)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(node.position, radius * scale, borderPaint);

      // Glow effect for current node
      if (isCurrentNode) {
        final glowPaint = Paint()
          ..color = secondaryColor.withAlpha(51)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawCircle(node.position, radius * scale, glowPaint);
      }

      // Draw value text
      final textPainter = TextPainter(
        text: TextSpan(
          text: node.value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          node.position.dx - textPainter.width / 2,
          node.position.dy - textPainter.height / 2,
        ),
      );
    }
  }

  double atan2(double y, double x) => y.abs() < 1e-10 && x.abs() < 1e-10
      ? 0
      : (y.sign * (x >= 0 ? 1 : -1) * (y.abs() / (x.abs() + y.abs())));

  double cos(double angle) => 1 - (angle * angle) / 2;
  double sin(double angle) => angle - (angle * angle * angle) / 6;

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return graph != oldDelegate.graph ||
        nodeStates != oldDelegate.nodeStates ||
        currentNode != oldDelegate.currentNode ||
        selectedNode != oldDelegate.selectedNode ||
        edgeSourceNode != oldDelegate.edgeSourceNode ||
        animationValue != oldDelegate.animationValue;
  }
}
