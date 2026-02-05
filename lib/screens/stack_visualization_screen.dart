import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stack_provider.dart';
import '../widgets/visualizers/stack_visualizer.dart';
import '../widgets/common/control_panel.dart';
import '../widgets/common/operation_button.dart';
import '../widgets/common/value_input_dialog.dart';
import '../widgets/common/complexity_display.dart';
import '../utils/constants.dart';

/// Stack Visualization Screen
class StackVisualizationScreen extends StatelessWidget {
  const StackVisualizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StackProvider(),
      child: const _StackVisualizationContent(),
    );
  }
}

class _StackVisualizationContent extends StatelessWidget {
  const _StackVisualizationContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stack Visualization'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<StackProvider>(
            builder: (context, provider, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    'Size: ${provider.size}/${AppConstants.maxStackSize}',
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
        // Operations & Details in tabs or scrolling
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
    return Consumer<StackProvider>(
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
                  label: 'Push',
                  icon: Icons.add_box,
                  color: AppConstants.primaryColor,
                  enabled: !isAnimating && !provider.isFull,
                  onPressed: () => _showPushDialog(context, provider),
                ),
                const SizedBox(height: 8),
                OperationButton(
                  label: 'Pop',
                  icon: Icons.remove_circle,
                  color: AppConstants.errorColor,
                  enabled: !isAnimating && !provider.isEmpty,
                  onPressed: () => provider.pop(),
                ),
                const SizedBox(height: 8),
                OperationButton(
                  label: 'Peek',
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
    return Consumer<StackProvider>(
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
            // Stack Visualizer with pan/zoom support
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.5,
                  maxScale: 2.0,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: (provider.items.length + 2) * 60.0 + 150,
                    child: StackVisualizer(
                      items: provider.items,
                      animatingNode: provider.animatingNode,
                      currentOperation: provider.currentOperation,
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
    return Consumer<StackProvider>(
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
                const ComplexityDisplay(operation: 'push', dsType: 'stack'),
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

  Color _getStatusColor(StackProvider provider) {
    if (provider.statusMessage?.contains('Overflow') == true ||
        provider.statusMessage?.contains('Underflow') == true) {
      return AppConstants.errorColor;
    }
    if (provider.statusMessage?.contains('Pushed') == true) {
      return AppConstants.secondaryColor;
    }
    if (provider.statusMessage?.contains('Popped') == true) {
      return AppConstants.warningColor;
    }
    return AppConstants.primaryColor;
  }

  void _showPushDialog(BuildContext context, StackProvider provider) {
    showDialog(
      context: context,
      builder: (context) => ValueInputDialog(
        title: 'Push Value',
        hint: 'Enter a number (0-99)',
        onSubmit: (value) {
          provider.push(value);
        },
      ),
    );
  }
}
