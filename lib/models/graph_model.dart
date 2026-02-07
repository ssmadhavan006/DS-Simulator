import 'package:flutter/material.dart';

/// Graph Node model
class GraphNode {
  final String id;
  final int value;
  Offset position; // For rendering and dragging
  final DateTime createdAt;

  GraphNode({required this.value, String? id, Offset? position})
    : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      position = position ?? Offset.zero,
      createdAt = DateTime.now();

  GraphNode copyWith({int? value, Offset? position}) {
    return GraphNode(
      value: value ?? this.value,
      id: id,
      position: position ?? this.position,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphNode && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GraphNode($value)';
}

/// Graph Edge model
class GraphEdge {
  final String id;
  final GraphNode source;
  final GraphNode target;
  final int weight;
  final bool isDirected;
  final DateTime createdAt;

  GraphEdge({
    required this.source,
    required this.target,
    this.weight = 1,
    this.isDirected = false,
    String? id,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
       createdAt = DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphEdge && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Edge(${source.value} → ${target.value}, weight: $weight)';
}

/// Graph Model with adjacency list
class GraphModel {
  final List<GraphNode> _nodes = [];
  final List<GraphEdge> _edges = [];
  bool isDirected;

  GraphModel({this.isDirected = false});

  // Getters
  List<GraphNode> get nodes => List.unmodifiable(_nodes);
  List<GraphEdge> get edges => List.unmodifiable(_edges);
  int get nodeCount => _nodes.length;
  int get edgeCount => _edges.length;

  /// Add a node
  GraphNode addNode(int value, {Offset? position}) {
    final node = GraphNode(value: value, position: position);
    _nodes.add(node);
    return node;
  }

  /// Remove a node and all connected edges
  void removeNode(GraphNode node) {
    _nodes.remove(node);
    _edges.removeWhere((edge) => edge.source == node || edge.target == node);
  }

  /// Add an edge
  GraphEdge? addEdge(GraphNode source, GraphNode target, {int weight = 1}) {
    // Check if edge already exists
    if (_edgeExists(source, target)) return null;

    final edge = GraphEdge(
      source: source,
      target: target,
      weight: weight,
      isDirected: isDirected,
    );
    _edges.add(edge);
    return edge;
  }

  /// Remove an edge
  void removeEdge(GraphEdge edge) {
    _edges.remove(edge);
  }

  /// Check if edge exists
  bool _edgeExists(GraphNode source, GraphNode target) {
    return _edges.any((edge) {
      if (isDirected) {
        return edge.source == source && edge.target == target;
      } else {
        return (edge.source == source && edge.target == target) ||
            (edge.source == target && edge.target == source);
      }
    });
  }

  /// Get neighbors of a node
  List<GraphNode> getNeighbors(GraphNode node) {
    final neighbors = <GraphNode>[];
    for (final edge in _edges) {
      if (edge.source == node) {
        neighbors.add(edge.target);
      } else if (!isDirected && edge.target == node) {
        neighbors.add(edge.source);
      }
    }
    return neighbors;
  }

  /// Build adjacency list
  Map<GraphNode, List<GraphNode>> get adjacencyList {
    final adjList = <GraphNode, List<GraphNode>>{};
    for (final node in _nodes) {
      adjList[node] = getNeighbors(node);
    }
    return adjList;
  }

  /// Clear all nodes and edges
  void clear() {
    _nodes.clear();
    _edges.clear();
  }

  @override
  String toString() => 'Graph(nodes: $nodeCount, edges: $edgeCount)';
}

/// Graph operation for history
class GraphOperation {
  final String
  type; // 'addNode', 'addEdge', 'removeNode', 'removeEdge', 'bfs', 'dfs'
  final int? value;
  final DateTime timestamp;

  GraphOperation({required this.type, this.value}) : timestamp = DateTime.now();

  @override
  String toString() => 'GraphOperation($type)';
}
