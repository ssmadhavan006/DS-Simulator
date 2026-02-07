import 'package:flutter/material.dart';
import 'dart:collection';
import 'dart:math' as math;
import '../models/graph_model.dart';
import '../utils/constants.dart';

/// Animation states for graph
enum AnimationState { idle, bfs, dfs, dijkstra, editing }

/// Node states during algorithm execution
enum NodeState { unvisited, visiting, visited }

/// Graph Provider for state management
class GraphProvider extends ChangeNotifier {
  final GraphModel _graph = GraphModel();
  final List<GraphOperation> _history = [];

  // Animation state
  AnimationState _animationState = AnimationState.idle;
  final Map<GraphNode, NodeState> _nodeStates = {};
  GraphNode? _currentNode;
  final List<GraphNode> _visitedSequence = [];
  String? _statusMessage;
  double _animationSpeed = AppConstants.speedDefault;
  String? _currentOperation; // For Code Preview

  // Edit mode
  GraphNode? _selectedNode;
  GraphNode? _edgeSourceNode;

  // Dijkstra state
  final Map<GraphNode, int> _distances = {};
  final Map<GraphNode, GraphNode?> _previous = {};
  final List<GraphEdge> _shortestPath = [];

  // Getters
  GraphModel get graph => _graph;
  List<GraphOperation> get history => List.unmodifiable(_history);
  AnimationState get animationState => _animationState;
  Map<GraphNode, NodeState> get nodeStates => _nodeStates;
  GraphNode? get currentNode => _currentNode;
  List<GraphNode> get visitedSequence => _visitedSequence;
  String? get statusMessage => _statusMessage;
  double get animationSpeed => _animationSpeed;
  String? get currentOperation => _currentOperation;
  GraphNode? get selectedNode => _selectedNode;
  GraphNode? get edgeSourceNode => _edgeSourceNode;

  bool get isDirected => _graph.isDirected;
  int get nodeCount => _graph.nodeCount;
  int get edgeCount => _graph.edgeCount;
  Map<GraphNode, int> get distances => _distances;
  List<GraphEdge> get shortestPath => _shortestPath;

  /// Add a node at position
  void addNode(int value, Offset position) {
    if (_graph.nodeCount >= AppConstants.maxGraphNodes) {
      _statusMessage = 'Maximum nodes reached!';
      notifyListeners();
      return;
    }

    _graph.addNode(value, position: position);
    _history.add(GraphOperation(type: 'addNode', value: value));
    _statusMessage = 'Added node $value';
    notifyListeners();
  }

  /// Remove a node
  void removeNode(GraphNode node) {
    _graph.removeNode(node);
    _nodeStates.remove(node);
    _history.add(GraphOperation(type: 'removeNode', value: node.value));
    _statusMessage = 'Removed node ${node.value}';
    notifyListeners();
  }

  /// Select node for edge creation
  void selectNodeForEdge(GraphNode node) {
    if (_edgeSourceNode == null) {
      _edgeSourceNode = node;
      _statusMessage = 'Select target node for edge';
    } else {
      _graph.addEdge(_edgeSourceNode!, node);
      _history.add(GraphOperation(type: 'addEdge'));
      _statusMessage = 'Added edge: ${_edgeSourceNode!.value} → ${node.value}';
      _edgeSourceNode = null;
    }
    notifyListeners();
  }

  /// Cancel edge selection
  void cancelEdgeSelection() {
    _edgeSourceNode = null;
    _statusMessage = null;
    notifyListeners();
  }

  /// Update node position (for dragging)
  void updateNodePosition(GraphNode node, Offset newPosition) {
    node.position = newPosition;
    notifyListeners();
  }

  /// Toggle directed/undirected
  void toggleGraphType() {
    _graph.isDirected = !_graph.isDirected;
    _statusMessage = _graph.isDirected ? 'Directed graph' : 'Undirected graph';
    notifyListeners();
  }

  /// Breadth-First Search animation
  Future<void> bfs(GraphNode startNode) async {
    if (_animationState != AnimationState.idle) return;

    _animationState = AnimationState.bfs;
    _nodeStates.clear();
    _visitedSequence.clear();
    _statusMessage = 'BFS from node ${startNode.value}';
    _currentOperation = 'bfs';

    // Initialize all nodes as unvisited
    for (final node in _graph.nodes) {
      _nodeStates[node] = NodeState.unvisited;
    }
    notifyListeners();

    final queue = Queue<GraphNode>();
    queue.add(startNode);
    _nodeStates[startNode] = NodeState.visiting;

    while (queue.isNotEmpty) {
      _currentNode = queue.removeFirst();
      _nodeStates[_currentNode!] = NodeState.visited;
      _visitedSequence.add(_currentNode!);
      notifyListeners();

      await Future.delayed(_getAnimationDuration());

      for (final neighbor in _graph.getNeighbors(_currentNode!)) {
        if (_nodeStates[neighbor] == NodeState.unvisited) {
          _nodeStates[neighbor] = NodeState.visiting;
          queue.add(neighbor);
          notifyListeners();
          await Future.delayed(_getAnimationDuration() ~/ 2);
        }
      }
    }

    _statusMessage =
        'BFS complete: ${_visitedSequence.map((n) => n.value).join(", ")}';
    _history.add(GraphOperation(type: 'bfs', value: startNode.value));
    await Future.delayed(Duration(seconds: 1));

    _animationState = AnimationState.idle;
    _currentNode = null;
    _currentOperation = null;
    notifyListeners();
  }

  /// Depth-First Search animation
  Future<void> dfs(GraphNode startNode) async {
    if (_animationState != AnimationState.idle) return;

    _animationState = AnimationState.dfs;
    _nodeStates.clear();
    _visitedSequence.clear();
    _statusMessage = 'DFS from node ${startNode.value}';
    _currentOperation = 'dfs';

    // Initialize all nodes as unvisited
    for (final node in _graph.nodes) {
      _nodeStates[node] = NodeState.unvisited;
    }
    notifyListeners();

    await _dfsRecursive(startNode);

    _statusMessage =
        'DFS complete: ${_visitedSequence.map((n) => n.value).join(", ")}';
    _history.add(GraphOperation(type: 'dfs', value: startNode.value));
    await Future.delayed(Duration(seconds: 1));

    _animationState = AnimationState.idle;
    _currentNode = null;
    _currentOperation = null;
    notifyListeners();
  }

  Future<void> _dfsRecursive(GraphNode node) async {
    _nodeStates[node] = NodeState.visiting;
    _currentNode = node;
    notifyListeners();
    await Future.delayed(_getAnimationDuration());

    _nodeStates[node] = NodeState.visited;
    _visitedSequence.add(node);
    notifyListeners();

    for (final neighbor in _graph.getNeighbors(node)) {
      if (_nodeStates[neighbor] == NodeState.unvisited) {
        await _dfsRecursive(neighbor);
      }
    }
  }

  /// Dijkstra's Algorithm (Shortest Path)
  Future<void> dijkstra(GraphNode startNode, GraphNode? endNode) async {
    if (_animationState != AnimationState.idle) return;

    _animationState = AnimationState.dijkstra;
    _nodeStates.clear();
    _visitedSequence.clear();
    _distances.clear();
    _previous.clear();
    _shortestPath.clear();
    _statusMessage = 'Dijkstra from node ${startNode.value}';
    _currentOperation = 'dijkstra';

    // Initialize distances
    for (final node in _graph.nodes) {
      _nodeStates[node] = NodeState.unvisited;
      _distances[node] = 999999; // "Infinity"
      _previous[node] = null;
    }
    _distances[startNode] = 0;
    notifyListeners();

    // Priority queue (simple list sorted by distance)
    final unvisited = List<GraphNode>.from(_graph.nodes);

    while (unvisited.isNotEmpty) {
      // Find node with minimum distance
      unvisited.sort(
        (a, b) => (_distances[a] ?? 999999).compareTo(_distances[b] ?? 999999),
      );
      _currentNode = unvisited.removeAt(0);

      if (_distances[_currentNode]! == 999999) {
        break; // Remaining nodes unreachable
      }

      _nodeStates[_currentNode!] = NodeState.visiting;
      notifyListeners();
      await Future.delayed(_getAnimationDuration());

      _nodeStates[_currentNode!] = NodeState.visited;
      _visitedSequence.add(_currentNode!);

      // Update distances for neighbors
      for (final neighbor in _graph.getNeighbors(_currentNode!)) {
        if (_nodeStates[neighbor] == NodeState.visited) continue;

        // Get edge weight
        final edge = _getEdge(_currentNode!, neighbor);
        final weight = edge?.weight ?? 1;
        final altDistance = _distances[_currentNode]! + weight;

        if (altDistance < (_distances[neighbor] ?? 999999)) {
          _distances[neighbor] = altDistance;
          _previous[neighbor] = _currentNode;
        }
      }
      notifyListeners();
      await Future.delayed(_getAnimationDuration() ~/ 2);
    }

    // Reconstruct shortest path if endNode specified
    if (endNode != null && _previous[endNode] != null) {
      GraphNode? current = endNode;
      while (current != null && _previous[current] != null) {
        final prev = _previous[current]!;
        final edge = _getEdge(prev, current);
        if (edge != null) _shortestPath.insert(0, edge);
        current = prev;
      }
      _statusMessage =
          'Shortest path to ${endNode.value}: distance ${_distances[endNode]}';
    } else {
      _statusMessage = 'Dijkstra complete from ${startNode.value}';
    }

    _history.add(GraphOperation(type: 'dijkstra', value: startNode.value));
    await Future.delayed(Duration(seconds: 1));

    _animationState = AnimationState.idle;
    _currentNode = null;
    _currentOperation = null;
    notifyListeners();
  }

  /// Helper to find edge between two nodes
  GraphEdge? _getEdge(GraphNode source, GraphNode target) {
    for (final edge in _graph.edges) {
      if (edge.source == source && edge.target == target) return edge;
      if (!_graph.isDirected &&
          edge.source == target &&
          edge.target == source) {
        return edge;
      }
    }
    return null;
  }

  /// Generate a random graph
  void generateRandom(int nodeCount) {
    clear();
    final random = math.Random();
    final nodes = <GraphNode>[];

    // Create nodes in a circle pattern
    for (int i = 0; i < nodeCount; i++) {
      final angle = (2 * math.pi * i) / nodeCount;
      final x = 250 + 150 * math.cos(angle);
      final y = 250 + 150 * math.sin(angle);
      final value = random.nextInt(100);
      final node = _graph.addNode(value, position: Offset(x, y));
      nodes.add(node);
    }

    // Add random edges
    for (int i = 0; i < nodeCount; i++) {
      // Connect to next node in circle
      _graph.addEdge(nodes[i], nodes[(i + 1) % nodeCount]);

      // Add some random connections
      if (random.nextDouble() > 0.5 && nodeCount > 3) {
        final target = random.nextInt(nodeCount);
        if (target != i) {
          _graph.addEdge(nodes[i], nodes[target]);
        }
      }
    }

    _statusMessage = 'Generated random graph';
    notifyListeners();
  }

  /// Clear graph
  void clear() {
    _graph.clear();
    _nodeStates.clear();
    _visitedSequence.clear();
    _distances.clear();
    _previous.clear();
    _shortestPath.clear();
    _history.clear();
    _currentNode = null;
    _selectedNode = null;
    _edgeSourceNode = null;
    _animationState = AnimationState.idle;
    _statusMessage = 'Graph cleared';
    _currentOperation = null;
    notifyListeners();
  }

  /// Set animation speed
  void setSpeed(double speed) {
    _animationSpeed = speed;
    notifyListeners();
  }

  // Helper methods
  Duration _getAnimationDuration() {
    return Duration(
      milliseconds:
          (AppConstants.animationNormal.inMilliseconds / _animationSpeed)
              .round(),
    );
  }
}
