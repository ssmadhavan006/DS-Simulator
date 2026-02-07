import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/graph_provider.dart';
import '../widgets/visualizers/graph_visualizer.dart';
import '../widgets/common/control_panel.dart';
import '../widgets/common/operation_button.dart';
import '../widgets/common/value_input_dialog.dart';
import '../widgets/common/complexity_display.dart';
import '../widgets/common/code_preview.dart';
import '../widgets/common/zoomable_visualization.dart';
import '../utils/constants.dart';

/// Graph Visualization Screen
class GraphVisualizationScreen extends StatelessWidget {
  const GraphVisualizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GraphProvider(),
      child: const _GraphVisualizationContent(),
    );
  }
}

class _GraphVisualizationContent extends StatelessWidget {
  const _GraphVisualizationContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<GraphProvider>(
          builder: (context, provider, _) {
            return Text(
              provider.isDirected ? 'Directed Graph' : 'Undirected Graph',
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<GraphProvider>(
            builder: (context, provider, _) {
              return Row(
                children: [
                  IconButton(
                    icon: Icon(
                      provider.isDirected
                          ? Icons.arrow_forward
                          : Icons.swap_horiz,
                    ),
                    onPressed: provider.toggleGraphType,
                    tooltip: provider.isDirected
                        ? 'Switch to Undirected'
                        : 'Switch to Directed',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: Text(
                        'Nodes: ${provider.nodeCount} | Edges: ${provider.edgeCount}',
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
    return Consumer<GraphProvider>(
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
                  'Graph Operations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                OperationButton(
                  label: 'Add Node',
                  icon: Icons.add_circle,
                  color: AppConstants.primaryColor,
                  enabled:
                      !isAnimating &&
                      provider.nodeCount < AppConstants.maxGraphNodes,
                  onPressed: () => _showAddNodeDialog(context, provider),
                ),
                const SizedBox(height: 8),
                OperationButton(
                  label: provider.edgeSourceNode != null
                      ? 'Select Target'
                      : 'Add Edge',
                  icon: Icons.link,
                  color: provider.edgeSourceNode != null
                      ? Colors.orange
                      : AppConstants.secondaryColor,
                  enabled: !isAnimating && provider.nodeCount >= 2,
                  onPressed: () {
                    if (provider.edgeSourceNode != null) {
                      provider.cancelEdgeSelection();
                    }
                  },
                ),
                const Divider(height: 24),
                Text(
                  'Algorithms',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                OperationButton(
                  label: 'BFS',
                  icon: Icons.blur_on,
                  color: Colors.purple,
                  enabled: !isAnimating && provider.nodeCount > 0,
                  onPressed: () => _selectStartNode(context, provider, true),
                ),
                const SizedBox(height: 8),
                OperationButton(
                  label: 'DFS',
                  icon: Icons.vertical_split,
                  color: Colors.indigo,
                  enabled: !isAnimating && provider.nodeCount > 0,
                  onPressed: () => _selectStartNode(context, provider, false),
                ),
                const SizedBox(height: 8),
                OperationButton(
                  label: 'Dijkstra',
                  icon: Icons.route,
                  color: Colors.teal,
                  enabled: !isAnimating && provider.nodeCount > 0,
                  onPressed: () => _runDijkstra(context, provider),
                ),
                const Divider(height: 24),
                OperationButton(
                  label: 'Random (6)',
                  icon: Icons.shuffle,
                  color: Colors.orange,
                  enabled: !isAnimating,
                  onPressed: () => provider.generateRandom(6),
                ),
                const SizedBox(height: 8),
                OperationButton(
                  label: 'Clear',
                  icon: Icons.delete_sweep,
                  color: Colors.grey,
                  enabled: !isAnimating && provider.nodeCount > 0,
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
    return Consumer<GraphProvider>(
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
            // Instructions for adding edges
            if (provider.edgeSourceNode != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(31),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tap another node to create edge',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            // Graph Visualizer
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ZoomableVisualization(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: SizedBox(
                    width: 600,
                    height: 600,
                    child: GraphVisualizer(
                      graph: provider.graph,
                      nodeStates: provider.nodeStates,
                      currentNode: provider.currentNode,
                      selectedNode: provider.selectedNode,
                      edgeSourceNode: provider.edgeSourceNode,
                      onNodeDragged: provider.updateNodePosition,
                      onNodeTapped: (node) {
                        if (provider.edgeSourceNode != null) {
                          provider.selectNodeForEdge(node);
                        }
                      },
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
    return Consumer<GraphProvider>(
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
                              operation: 'bfs',
                              dsType: 'graph',
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
                          operation: provider.currentOperation ?? 'bfs',
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

  void _showAddNodeDialog(BuildContext context, GraphProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => ValueInputDialog(
        title: 'Add Node',
        hint: 'Enter node value (0-99)',
        onSubmit: (value) {
          // Add node at center with random offset
          final random = (value * 17) % 360;
          final angle = random * 3.14159 / 180;
          final offset = Offset(
            300 + 100 * (angle / 3.14159),
            300 + 100 * ((angle / 3.14159) * 0.5),
          );
          provider.addNode(value, offset);
        },
      ),
    );
  }

  void _selectStartNode(
    BuildContext context,
    GraphProvider provider,
    bool isBFS,
  ) {
    if (provider.graph.nodes.isEmpty) return;

    final startNode = provider.graph.nodes.first;
    if (isBFS) {
      provider.bfs(startNode);
    } else {
      provider.dfs(startNode);
    }
  }

  void _runDijkstra(BuildContext context, GraphProvider provider) {
    if (provider.graph.nodes.isEmpty) return;
    // Run Dijkstra from first node (simple approach)
    final startNode = provider.graph.nodes.first;
    final endNode = provider.graph.nodes.length > 1
        ? provider.graph.nodes.last
        : null;
    provider.dijkstra(startNode, endNode);
  }
}
