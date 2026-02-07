import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../models/tree_node.dart';
import '../utils/constants.dart';

/// Animation states for tree operations
enum AnimationState {
  idle,
  inserting,
  deleting,
  searching,
  traversing,
  rotating,
}

/// Tree Provider for BST and AVL state management
class TreeProvider extends ChangeNotifier {
  TreeNode? _root;
  final AVLTree _avlTree = AVLTree();
  final List<TreeOperation> _history = [];

  // Mode toggle
  bool _isAVLMode = false;

  // Animation state
  AnimationState _animationState = AnimationState.idle;
  TreeNode? _animatingNode;
  List<TreeNode> _animatingPath = [];
  int _traversalIndex = 0;
  String? _statusMessage;
  double _animationSpeed = AppConstants.speedDefault;
  String? _lastRotation; // Track rotation for animation
  String? _currentOperation; // For Code Preview

  // Getters
  TreeNode? get root => _isAVLMode ? _avlTree.root : _root;
  List<TreeOperation> get history => List.unmodifiable(_history);
  AnimationState get animationState => _animationState;
  TreeNode? get animatingNode => _animatingNode;
  List<TreeNode> get animatingPath => _animatingPath;
  int get traversalIndex => _traversalIndex;
  String? get statusMessage => _statusMessage;
  double get animationSpeed => _animationSpeed;
  bool get isAVLMode => _isAVLMode;
  String? get lastRotation => _lastRotation;
  String? get currentOperation => _currentOperation;

  int get size => root?.size ?? 0;
  int get height => root?.height ?? 0;
  bool get isEmpty => root == null;

  /// Toggle between BST and AVL mode
  void toggleAVLMode() {
    _isAVLMode = !_isAVLMode;
    clear();
    _statusMessage = _isAVLMode ? 'AVL Mode (Self-Balancing)' : 'BST Mode';
    notifyListeners();
  }

  /// Insert a value into the tree
  Future<bool> insert(int value) async {
    if (_animationState != AnimationState.idle) return false;

    _animationState = AnimationState.inserting;
    _statusMessage = 'Inserting $value...';
    _lastRotation = null;
    _currentOperation = 'insert_bst';
    notifyListeners();

    await Future.delayed(_getAnimationDuration());

    if (_isAVLMode) {
      // AVL insert with balancing
      int oldHeight = height;
      _avlTree.insert(value);

      // Check if rotation occurred
      if (_avlTree.root != null && height < oldHeight + 1) {
        _lastRotation = 'Balanced!';
        _statusMessage = 'Inserted $value (tree rebalanced)';
      } else {
        _statusMessage = 'Inserted $value';
      }
      _animatingNode = _findNode(_avlTree.root, value);
    } else {
      // Standard BST insert
      if (_root == null) {
        _root = TreeNode(value: value);
        _animatingNode = _root;
      } else {
        _animatingPath = _findInsertionPath(value);
        _animatingNode = _root!.insert(value);
      }
      _statusMessage = 'Inserted $value';
    }

    _history.add(
      TreeOperation(type: 'insert', value: value, rotationType: _lastRotation),
    );

    await Future.delayed(_getAnimationDuration());

    _animationState = AnimationState.idle;
    _animatingNode = null;
    _animatingPath = [];
    _currentOperation = null;
    notifyListeners();

    return true;
  }

  /// Search for a value
  Future<bool> search(int value) async {
    if (_animationState != AnimationState.idle || root == null) return false;

    _animationState = AnimationState.searching;
    _statusMessage = 'Searching for $value...';
    _currentOperation = 'search_bst';
    notifyListeners();

    _animatingPath = root!.search(value);

    for (int i = 0; i < _animatingPath.length; i++) {
      _animatingNode = _animatingPath[i];
      notifyListeners();
      await Future.delayed(_getAnimationDuration());
    }

    bool found =
        _animatingPath.isNotEmpty && _animatingPath.last.value == value;

    _statusMessage = found ? 'Found $value!' : '$value not found in tree';
    _history.add(TreeOperation(type: 'search', value: value));

    await Future.delayed(_getAnimationDuration());

    _animationState = AnimationState.idle;
    _animatingNode = null;
    _animatingPath = [];
    _currentOperation = null;
    notifyListeners();

    return found;
  }

  /// Perform traversal animation
  Future<void> traverse(TraversalType type) async {
    if (_animationState != AnimationState.idle || root == null) return;

    _animationState = AnimationState.traversing;
    _statusMessage = 'Traversing: ${type.description}';
    _currentOperation = type.name; // inOrder, preOrder, postOrder
    notifyListeners();

    List<TreeNode> sequence;
    switch (type) {
      case TraversalType.inOrder:
        sequence = root!.inOrderTraversal();
        break;
      case TraversalType.preOrder:
        sequence = root!.preOrderTraversal();
        break;
      case TraversalType.postOrder:
        sequence = root!.postOrderTraversal();
        break;
    }

    for (int i = 0; i < sequence.length; i++) {
      _traversalIndex = i;
      _animatingNode = sequence[i];
      notifyListeners();
      await Future.delayed(_getAnimationDuration());
    }

    _statusMessage =
        '${type.title} complete: ${sequence.map((n) => n.value).join(", ")}';
    _history.add(TreeOperation(type: 'traverse: ${type.title}'));

    await Future.delayed(Duration(milliseconds: 500));

    _animationState = AnimationState.idle;
    _animatingNode = null;
    _traversalIndex = 0;
    _currentOperation = null;
    notifyListeners();
  }

  /// Generate random tree
  Future<void> generateRandom(int count) async {
    clear();
    final random = math.Random();
    final values = List.generate(count, (_) => random.nextInt(100));

    for (final value in values) {
      await insert(value);
    }
  }

  /// Clear the tree
  void clear() {
    _root = null;
    _avlTree.clear();
    _history.clear();
    _animationState = AnimationState.idle;
    _animatingNode = null;
    _animatingPath = [];
    _lastRotation = null;
    _statusMessage = 'Tree cleared';
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

  List<TreeNode> _findInsertionPath(int value) {
    List<TreeNode> path = [];
    TreeNode? current = _root;

    while (current != null) {
      path.add(current);
      if (value < current.value) {
        current = current.left;
      } else {
        current = current.right;
      }
    }

    return path;
  }

  TreeNode? _findNode(TreeNode? node, int value) {
    if (node == null) return null;
    if (node.value == value) return node;
    if (value < node.value) return _findNode(node.left, value);
    return _findNode(node.right, value);
  }
}
