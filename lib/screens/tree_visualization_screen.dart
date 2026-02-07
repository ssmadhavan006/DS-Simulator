import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tree_provider.dart';
import '../models/tree_node.dart';
import '../widgets/visualizers/tree_visualizer.dart';
import '../widgets/common/control_panel.dart';
import '../widgets/common/operation_button.dart';
import '../widgets/common/value_input_dialog.dart';
import '../widgets/common/complexity_display.dart';
import '../widgets/common/code_preview.dart';
import '../widgets/common/zoomable_visualization.dart';
import '../utils/constants.dart';

/// Tree Visualization Screen (BST)
class TreeVisualizationScreen extends StatelessWidget {
  const TreeVisualizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TreeProvider(),
      child: const _TreeVisualizationContent(),
    );
  }
}

class _TreeVisualizationContent extends StatelessWidget {
  const _TreeVisualizationContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<TreeProvider>(
          builder: (context, provider, _) {
            return Text(
              provider.isAVLMode
                  ? 'AVL Tree (Self-Balancing)'
                  : 'Binary Search Tree',
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<TreeProvider>(
            builder: (context, provider, _) {
              return Row(
                children: [
                  // AVL Mode Toggle
                  IconButton(
                    icon: Icon(
                      provider.isAVLMode ? Icons.balance : Icons.account_tree,
                      color: provider.isAVLMode
                          ? AppConstants.secondaryColor
                          : null,
                    ),
                    onPressed: provider.toggleAVLMode,
                    tooltip: provider.isAVLMode
                        ? 'Switch to BST'
                        : 'Switch to AVL',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: Text(
                        'Nodes: ${provider.size} | Height: ${provider.height}',
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
    return Consumer<TreeProvider>(
      builder: (context, provider, _) {
        final isAnimating = provider.animationState != AnimationState.idle;

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
                Text(
                  'Operations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                OperationButton(
                  label: 'Insert Node',
                  icon: Icons.add_circle,
                  color: AppConstants.primaryColor,
                  enabled:
                      !isAnimating && provider.size < AppConstants.maxTreeNodes,
                  onPressed: () => _showInsertDialog(context, provider),
                ),
                const SizedBox(height: 8),
                OperationButton(
                  label: 'Search Node',
                  icon: Icons.search,
                  color: AppConstants.secondaryColor,
                  enabled: !isAnimating && !provider.isEmpty,
                  onPressed: () => _showSearchDialog(context, provider),
                ),
                const Divider(height: 24),
                Text(
                  'Traversals',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                OperationButton(
                  label: 'In-Order',
                  icon: Icons.call_split,
                  color: Colors.purple,
                  enabled: !isAnimating && !provider.isEmpty,
                  onPressed: () => provider.traverse(TraversalType.inOrder),
                ),
                const SizedBox(height: 8),
                OperationButton(
                  label: 'Pre-Order',
                  icon: Icons.arrow_right_alt,
                  color: Colors.indigo,
                  enabled: !isAnimating && !provider.isEmpty,
                  onPressed: () => provider.traverse(TraversalType.preOrder),
                ),
                const SizedBox(height: 8),
                OperationButton(
                  label: 'Post-Order',
                  icon: Icons.subdirectory_arrow_right,
                  color: Colors.cyan,
                  enabled: !isAnimating && !provider.isEmpty,
                  onPressed: () => provider.traverse(TraversalType.postOrder),
                ),
                const Divider(height: 24),
                OperationButton(
                  label: 'Random (7)',
                  icon: Icons.shuffle,
                  color: Colors.orange,
                  enabled: !isAnimating,
                  onPressed: () => provider.generateRandom(7),
                ),
                const SizedBox(height: 8),
                OperationButton(
                  label: 'Clear',
                  icon: Icons.delete_sweep,
                  color: Colors.grey,
                  enabled: !isAnimating && !provider.isEmpty,
                  onPressed: () => provider.clear(),
                ),
                const SizedBox(height: 16),
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
    return Consumer<TreeProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // Status Message
            if (provider.statusMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withAlpha(31),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppConstants.primaryColor.withAlpha(127),
                  ),
                ),
                child: Text(
                  provider.statusMessage!,
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            // Tree Visualizer with pan/zoom
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ZoomableVisualization(
                  minScale: 0.3,
                  maxScale: 3.0,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 1.5,
                    height: (provider.height + 1) * 100.0 + 100,
                    child: TreeVisualizer(
                      root: provider.root,
                      animatingNode: provider.animatingNode,
                      animatingPath: provider.animatingPath,
                      showBalanceFactor: provider.isAVLMode,
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
    return Consumer<TreeProvider>(
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
                      Padding(
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
                            const ComplexityDisplay(
                              operation: 'insert_bst',
                              dsType: 'tree',
                            ),
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
                                      provider.history[provider.history.length -
                                          1 -
                                          index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      '${op.type}${op.value != null ? "(${op.value})" : ""}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Code Tab
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CodePreview(
                          operation: provider.currentOperation ?? 'insert_bst',
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

  void _showInsertDialog(BuildContext context, TreeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => ValueInputDialog(
        title: 'Insert Node',
        hint: 'Enter a number (0-99)',
        onSubmit: (value) {
          provider.insert(value);
        },
      ),
    );
  }

  void _showSearchDialog(BuildContext context, TreeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => ValueInputDialog(
        title: 'Search Node',
        hint: 'Enter a number to search',
        onSubmit: (value) {
          provider.search(value);
        },
      ),
    );
  }
}
