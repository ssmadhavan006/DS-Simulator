import 'package:flutter/material.dart';

/// A reusable widget that wraps content with zoom and pan support
/// using InteractiveViewer
class ZoomableVisualization extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final double initialScale;
  final bool showControls;

  const ZoomableVisualization({
    super.key,
    required this.child,
    this.minScale = 0.5,
    this.maxScale = 3.0,
    this.initialScale = 1.0,
    this.showControls = true,
  });

  @override
  State<ZoomableVisualization> createState() => _ZoomableVisualizationState();
}

class _ZoomableVisualizationState extends State<ZoomableVisualization> {
  late TransformationController _transformationController;
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _currentScale = widget.initialScale;

    // Set initial scale if not 1.0
    if (widget.initialScale != 1.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setScale(widget.initialScale);
      });
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _setScale(double scale) {
    final clampedScale = scale.clamp(widget.minScale, widget.maxScale);
    final matrix = Matrix4.identity()
      ..scaleByDouble(clampedScale, clampedScale, 1.0, 1.0);
    _transformationController.value = matrix;
    setState(() {
      _currentScale = clampedScale;
    });
  }

  void _zoomIn() {
    _setScale(_currentScale + 0.25);
  }

  void _zoomOut() {
    _setScale(_currentScale - 0.25);
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    setState(() {
      _currentScale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Interactive viewer for zoom and pan
        InteractiveViewer(
          transformationController: _transformationController,
          minScale: widget.minScale,
          maxScale: widget.maxScale,
          boundaryMargin: const EdgeInsets.all(100),
          onInteractionEnd: (details) {
            // Update current scale from the transformation matrix
            final scale = _transformationController.value.getMaxScaleOnAxis();
            setState(() {
              _currentScale = scale;
            });
          },
          child: widget.child,
        ),
        // Zoom controls overlay
        if (widget.showControls)
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withAlpha(230),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _currentScale > widget.minScale
                        ? _zoomOut
                        : null,
                    icon: const Icon(Icons.remove),
                    iconSize: 20,
                    tooltip: 'Zoom Out',
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '${(_currentScale * 100).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _currentScale < widget.maxScale ? _zoomIn : null,
                    icon: const Icon(Icons.add),
                    iconSize: 20,
                    tooltip: 'Zoom In',
                  ),
                  IconButton(
                    onPressed: _currentScale != 1.0 ? _resetZoom : null,
                    icon: const Icon(Icons.fit_screen),
                    iconSize: 20,
                    tooltip: 'Reset Zoom',
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
