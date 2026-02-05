import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/queue_provider.dart';
import '../widgets/visualizers/queue_visualizer.dart';
import '../widgets/common/control_panel.dart';
import '../widgets/common/operation_button.dart';
import '../widgets/common/value_input_dialog.dart';
import '../widgets/common/complexity_display.dart';
import '../utils/constants.dart';

/// Queue Visualization Screen
class QueueVisualizationScreen extends StatelessWidget {
  const QueueVisualizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QueueProvider(),
      child: const _QueueVisualizationContent(),
    );
  }
}

class _QueueVisualizationContent extends StatelessWidget {
  const _QueueVisualizationContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<QueueProvider>(
          builder: (context, provider, _) {
            return Text(
              provider.isCircularMode
                  ? 'Circular Queue'
                  : 'Queue Visualization',
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<QueueProvider>(
            builder: (context, provider, _) {
              return Row(
                children: [
                  IconButton(
                    icon: Icon(
                      provider.isCircularMode
                          ? Icons.all_inclusive
                          : Icons.linear_scale,
                    ),
                    onPressed: provider.toggleCircularMode,
                    tooltip: provider.isCircularMode
                        ? 'Switch to Linear'
                        : 'Switch to Circular',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: Text(
                        'Size: ${provider.size}/${AppConstants.maxQueueSize}',
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ),
                ],
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
    return Consumer<QueueProvider>(
      builder: (context, provider, _) {
        final isAnimating = provider.animationState != AnimationState.idle;

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              right: BorderSide(color: theme.dividerColor, width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Operations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                OperationButton(
                  label: 'Enqueue',
                  icon: Icons.add_to_queue,
                  color: AppConstants.primaryColor,
                  enabled: !isAnimating && !provider.isFull,
                  onPressed: () => _showEnqueueDialog(context, provider),
                ),
                const SizedBox(height: 8),
                OperationButton(
                  label: 'Dequeue',
                  icon: Icons.remove_from_queue,
                  color: AppConstants.errorColor,
                  enabled: !isAnimating && !provider.isEmpty,
                  onPressed: () => provider.dequeue(),
                ),
                const SizedBox(height: 8),
                OperationButton(
                  label: 'Peek (Front)',
                  icon: Icons.visibility,
                  color: AppConstants.secondaryColor,
                  enabled: !isAnimating && !provider.isEmpty,
                  onPressed: () => provider.peek(),
                ),
                const Divider(height: 32),
                OperationButton(
                  label: 'Random (5)',
                  icon: Icons.shuffle,
                  color: Colors.orange,
                  enabled: !isAnimating,
                  onPressed: () => provider.generateRandom(5),
                ),
                const SizedBox(height: 8),
                OperationButton(
                  label: 'Clear',
                  icon: Icons.delete_sweep,
                  color: Colors.grey,
                  enabled: !isAnimating && !provider.isEmpty,
                  onPressed: () => provider.clear(),
                ),
                const Spacer(),
                // Speed Control
                ControlPanel(
                  speed: provider.animationSpeed,
                  onSpeedChanged: provider.setSpeed,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisualizationArea(BuildContext context, ThemeData theme) {
    return Consumer<QueueProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // Status Message - fixed at top
            if (provider.statusMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(provider).withAlpha(31),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(provider).withAlpha(127),
                  ),
                ),
                child: Text(
                  provider.statusMessage!,
                  style: TextStyle(
                    color: _getStatusColor(provider),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            // Queue Visualizer with pan/zoom support
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.5,
                  maxScale: 2.0,
                  child: SizedBox(
                    width: provider.isCircularMode
                        ? MediaQuery.of(context).size.width * 0.8
                        : (provider.items.length + 2) * 70.0 + 200,
                    height: provider.isCircularMode
                        ? MediaQuery.of(context).size.width * 0.8
                        : 200,
                    child: QueueVisualizer(
                      items: provider.items,
                      animatingNode: provider.animatingNode,
                      currentOperation: provider.currentOperation,
                      isCircular: provider.isCircularMode,
                      maxSize: AppConstants.maxQueueSize,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailsPanel(BuildContext context, ThemeData theme) {
    return Consumer<QueueProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              left: BorderSide(color: theme.dividerColor, width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const ComplexityDisplay(operation: 'enqueue', dsType: 'queue'),
                const Divider(height: 24),
                // Front/Rear indicators
                _buildPointerInfo('Front', provider.front?.value, theme),
                const SizedBox(height: 8),
                _buildPointerInfo('Rear', provider.rear?.value, theme),
                const Divider(height: 24),
                Text(
                  'History',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.history.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final op =
                          provider.history[provider.history.length - 1 - index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '${op.type}${op.node != null ? "(${op.node!.value})" : ""}',
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointerInfo(String label, int? value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(31),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value?.toString() ?? 'null',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(QueueProvider provider) {
    if (provider.statusMessage?.contains('Overflow') == true ||
        provider.statusMessage?.contains('Underflow') == true) {
      return AppConstants.errorColor;
    }
    if (provider.statusMessage?.contains('Enqueued') == true) {
      return AppConstants.secondaryColor;
    }
    if (provider.statusMessage?.contains('Dequeued') == true) {
      return AppConstants.warningColor;
    }
    return AppConstants.primaryColor;
  }

  void _showEnqueueDialog(BuildContext context, QueueProvider provider) {
    showDialog(
      context: context,
      builder: (context) => ValueInputDialog(
        title: 'Enqueue Value',
        hint: 'Enter a number (0-99)',
        onSubmit: (value) {
          provider.enqueue(value);
        },
      ),
    );
  }
}
