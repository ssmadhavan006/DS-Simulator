import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sorting_provider.dart';
import '../widgets/visualizers/sorting_visualizer.dart';
import '../widgets/common/operation_button.dart';
import '../widgets/common/code_preview.dart';
import '../widgets/common/zoomable_visualization.dart';
import '../utils/constants.dart';

/// Sorting Algorithms Visualization Screen
class SortingVisualizationScreen extends StatelessWidget {
  const SortingVisualizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SortingProvider(),
      child: const _SortingVisualizationContent(),
    );
  }
}

class _SortingVisualizationContent extends StatelessWidget {
  const _SortingVisualizationContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<SortingProvider>(
          builder: (context, provider, _) {
            return Text(provider.currentAlgorithm.name);
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<SortingProvider>(
            builder: (context, provider, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    'Size: ${provider.arraySize}',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isWide
          ? _buildWideLayout(context, theme)
          : _buildNarrowLayout(context, theme),
    );
  }

  Widget _buildWideLayout(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // Operations Panel
        SizedBox(
          width:
              MediaQuery.of(context).size.width *
              AppConstants.operationsPanelWidth,
          child: _buildOperationsPanel(context, theme),
        ),
        // Visualization Area
        Expanded(child: _buildVisualizationArea(context, theme)),
        // Details Panel
        SizedBox(
          width:
              MediaQuery.of(context).size.width *
              AppConstants.detailsPanelWidth,
          child: _buildDetailsPanel(context, theme),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Visualization Area
        Expanded(flex: 3, child: _buildVisualizationArea(context, theme)),
        // Operations & Details in tabs
        Expanded(
          flex: 2,
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: const [
                    Tab(text: 'Operations'),
                    Tab(text: 'Details'),
                  ],
                  labelColor: theme.colorScheme.primary,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildOperationsPanel(context, theme),
                      _buildDetailsPanel(context, theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOperationsPanel(BuildContext context, ThemeData theme) {
    return Consumer<SortingProvider>(
      builder: (context, provider, _) {
        final isSorting = provider.state == SortingState.sorting;
        final isPaused = provider.state == SortingState.paused;

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              right: BorderSide(color: theme.dividerColor, width: 1),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Algorithm Selection
                Text(
                  'Algorithm',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: provider.currentAlgorithm.name,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: provider.algorithms.map((algorithm) {
                      return DropdownMenuItem(
                        value: algorithm.name,
                        child: Text(algorithm.name),
                      );
                    }).toList(),
                    onChanged: isSorting
                        ? null
                        : (name) {
                            if (name != null) {
                              final algorithm = provider.algorithms.firstWhere(
                                (a) => a.name == name,
                              );
                              provider.setAlgorithm(algorithm);
                            }
                          },
                  ),
                ),
                const SizedBox(height: 16),

                // Array Size Slider
                Text(
                  'Array Size: ${provider.arraySize}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  value: provider.arraySize.toDouble(),
                  min: 5,
                  max: 100,
                  divisions: 19,
                  label: '${provider.arraySize}',
                  onChanged: isSorting
                      ? null
                      : (value) => provider.setArraySize(value.round()),
                ),
                const SizedBox(height: 8),

                // Speed Slider
                Text(
                  'Speed: ${provider.animationSpeed.toStringAsFixed(1)}x',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  value: provider.animationSpeed,
                  min: AppConstants.speedMin,
                  max: AppConstants.speedMax,
                  divisions: 9,
                  label: '${provider.animationSpeed.toStringAsFixed(1)}x',
                  onChanged: (value) => provider.setSpeed(value),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Control Buttons
                OperationButton(
                  label: 'Generate Random',
                  icon: Icons.shuffle,
                  color: Colors.blue,
                  enabled: !isSorting,
                  onPressed: provider.generateRandom,
                ),
                const SizedBox(height: 8),
                if (!isSorting && !isPaused) ...[
                  OperationButton(
                    label: 'Start Sort',
                    icon: Icons.play_arrow,
                    color: Colors.green,
                    onPressed: provider.startSort,
                  ),
                ] else if (isSorting) ...[
                  OperationButton(
                    label: 'Pause',
                    icon: Icons.pause,
                    color: Colors.orange,
                    onPressed: provider.pause,
                  ),
                ] else if (isPaused) ...[
                  OperationButton(
                    label: 'Resume',
                    icon: Icons.play_arrow,
                    color: Colors.green,
                    onPressed: provider.resume,
                  ),
                ],
                const SizedBox(height: 8),
                OperationButton(
                  label: 'Reset',
                  icon: Icons.refresh,
                  color: Colors.grey,
                  enabled: provider.state != SortingState.idle,
                  onPressed: provider.reset,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisualizationArea(BuildContext context, ThemeData theme) {
    return Consumer<SortingProvider>(
      builder: (context, provider, _) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Status Message
              if (provider.statusMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(provider.state),
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.statusMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              // Visualizer
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ZoomableVisualization(
                      minScale: 0.5,
                      maxScale: 2.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SortingVisualizer(
                          numbers: provider.numbers,
                          comparingIndices: provider.comparingIndices,
                          swappingIndices: provider.swappingIndices,
                          sortedIndices: provider.sortedIndices,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Legend
              _buildLegend(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem('Default', theme.colorScheme.primary),
          const SizedBox(width: 16),
          _legendItem('Comparing', Colors.amber),
          const SizedBox(width: 16),
          _legendItem('Swapping', Colors.red),
          const SizedBox(width: 16),
          _legendItem('Sorted', Colors.green),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDetailsPanel(BuildContext context, ThemeData theme) {
    return Consumer<SortingProvider>(
      builder: (context, provider, _) {
        return DefaultTabController(
          length: 2,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                left: BorderSide(color: theme.dividerColor, width: 1),
              ),
            ),
            child: Column(
              children: [
                TabBar(
                  tabs: const [
                    Tab(text: 'Info'),
                    Tab(text: 'Code'),
                  ],
                  labelColor: theme.colorScheme.primary,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Info Tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.currentAlgorithm.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildComplexityInfo(
                              'Best',
                              provider.currentAlgorithm.timeComplexityBest,
                              theme,
                            ),
                            _buildComplexityInfo(
                              'Average',
                              provider.currentAlgorithm.timeComplexityAverage,
                              theme,
                            ),
                            _buildComplexityInfo(
                              'Worst',
                              provider.currentAlgorithm.timeComplexityWorst,
                              theme,
                            ),
                            _buildComplexityInfo(
                              'Space',
                              provider.currentAlgorithm.spaceComplexity,
                              theme,
                            ),
                            const Divider(height: 24),
                            _buildPropertyInfo(
                              'Stable',
                              provider.currentAlgorithm.isStable ? 'Yes' : 'No',
                              theme,
                            ),
                          ],
                        ),
                      ),
                      // Code Tab
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CodePreview(
                          operation: provider.currentOperation ?? 'bubbleSort',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplexityInfo(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyInfo(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(SortingState state) {
    switch (state) {
      case SortingState.idle:
        return Icons.info_outline;
      case SortingState.sorting:
        return Icons.play_circle_outline;
      case SortingState.paused:
        return Icons.pause_circle_outline;
      case SortingState.complete:
        return Icons.check_circle_outline;
    }
  }
}
