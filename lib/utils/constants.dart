import 'package:flutter/material.dart';

/// App-wide constants for DSA Visualizer
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // App Info
  static const String appName = 'DSA Visualizer';
  static const String appVersion = '1.0.0';

  // Colors - Material 3 Design System
  static const Color primaryColor = Color(0xFF2962FF); // Blue
  static const Color secondaryColor = Color(0xFF00C853); // Green (success)
  static const Color errorColor = Color(0xFFFF1744); // Red (error/overflow)
  static const Color warningColor = Color(0xFFFF9100); // Orange (warning)

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2D2D2D);

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 400);
  static const Duration animationSlow = Duration(milliseconds: 800);

  // Speed Multipliers
  static const double speedMin = 0.5;
  static const double speedMax = 5.0;
  static const double speedDefault = 1.0;

  // Data Structure Limits
  static const int maxStackSize = 20;
  static const int maxQueueSize = 20;
  static const int maxTreeNodes = 31; // Full binary tree depth 4
  static const int maxGraphNodes = 15;

  // UI Dimensions
  static const double nodeSize = 50.0;
  static const double nodePadding = 8.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;

  // Layout Proportions
  static const double operationsPanelWidth = 0.25;
  static const double visualizationAreaWidth = 0.55;
  static const double detailsPanelWidth = 0.20;
  static const double controlPanelHeight = 80.0;

  // Time Complexity Labels
  static const Map<String, String> timeComplexity = {
    'push': 'O(1)',
    'pop': 'O(1)',
    'peek': 'O(1)',
    'enqueue': 'O(1)',
    'dequeue': 'O(1)',
    'insert_bst': 'O(log n)',
    'delete_bst': 'O(log n)',
    'search_bst': 'O(log n)',
    'bfs': 'O(V + E)',
    'dfs': 'O(V + E)',
  };

  // Space Complexity Labels
  static const Map<String, String> spaceComplexity = {
    'stack': 'O(n)',
    'queue': 'O(n)',
    'tree': 'O(n)',
    'graph': 'O(V + E)',
  };
}

/// Data Structure Types
enum DSType {
  stack('Stack', 'LIFO - Last In First Out'),
  queue('Queue', 'FIFO - First In First Out'),
  tree('Tree', 'Hierarchical Data Structure'),
  graph('Graph', 'Network of Nodes & Edges');

  final String title;
  final String description;
  const DSType(this.title, this.description);
}
