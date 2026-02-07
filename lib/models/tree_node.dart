import 'dart:math' as math;

/// Tree Node for Binary Search Tree and AVL Tree
class TreeNode {
  final String id;
  int value;
  TreeNode? left;
  TreeNode? right;

  // Rendering positions (calculated dynamically)
  double x = 0;
  double y = 0;

  // AVL specific - cached height for O(1) balance calculation
  int _height = 1;

  // Metadata
  final DateTime createdAt;

  TreeNode({required this.value, String? id, this.left, this.right})
    : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt = DateTime.now();

  /// Get cached height (for AVL)
  int get nodeHeight => _height;

  /// Update height based on children
  void updateHeight() {
    int leftH = left?._height ?? 0;
    int rightH = right?._height ?? 0;
    _height = 1 + math.max(leftH, rightH);
  }

  /// Get balance factor (for AVL): left height - right height
  int get balanceFactor {
    int leftH = left?._height ?? 0;
    int rightH = right?._height ?? 0;
    return leftH - rightH;
  }

  /// Insert a value into BST (returns the inserted node)
  TreeNode insert(int val) {
    if (val < value) {
      if (left == null) {
        left = TreeNode(value: val);
        return left!;
      } else {
        return left!.insert(val);
      }
    } else {
      if (right == null) {
        right = TreeNode(value: val);
        return right!;
      } else {
        return right!.insert(val);
      }
    }
  }

  /// Search for a value (returns path to node)
  List<TreeNode> search(int val) {
    List<TreeNode> path = [this];

    if (val == value) {
      return path;
    } else if (val < value && left != null) {
      path.addAll(left!.search(val));
      return path;
    } else if (val > value && right != null) {
      path.addAll(right!.search(val));
      return path;
    }

    return path; // Not found, returns partial path
  }

  /// Find minimum node in subtree
  TreeNode findMin() {
    return left == null ? this : left!.findMin();
  }

  /// In-order traversal (Left - Root - Right)
  List<TreeNode> inOrderTraversal() {
    List<TreeNode> result = [];
    if (left != null) result.addAll(left!.inOrderTraversal());
    result.add(this);
    if (right != null) result.addAll(right!.inOrderTraversal());
    return result;
  }

  /// Pre-order traversal (Root - Left - Right)
  List<TreeNode> preOrderTraversal() {
    List<TreeNode> result = [this];
    if (left != null) result.addAll(left!.preOrderTraversal());
    if (right != null) result.addAll(right!.preOrderTraversal());
    return result;
  }

  /// Post-order traversal (Left - Right - Root)
  List<TreeNode> postOrderTraversal() {
    List<TreeNode> result = [];
    if (left != null) result.addAll(left!.postOrderTraversal());
    if (right != null) result.addAll(right!.postOrderTraversal());
    result.add(this);
    return result;
  }

  /// Calculate tree height (dynamic, for display)
  int get height {
    int leftHeight = left?.height ?? 0;
    int rightHeight = right?.height ?? 0;
    return 1 + math.max(leftHeight, rightHeight);
  }

  /// Count total nodes in subtree
  int get size {
    int leftSize = left?.size ?? 0;
    int rightSize = right?.size ?? 0;
    return 1 + leftSize + rightSize;
  }

  @override
  String toString() => 'TreeNode($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreeNode && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// AVL Tree helper class with rotation methods
class AVLTree {
  TreeNode? root;

  /// Get height of a node (null-safe)
  int _getHeight(TreeNode? node) => node?._height ?? 0;

  /// Get balance factor of a node
  int _getBalance(TreeNode? node) {
    if (node == null) return 0;
    return _getHeight(node.left) - _getHeight(node.right);
  }

  /// Right rotation (LL case)
  TreeNode _rotateRight(TreeNode y) {
    TreeNode x = y.left!;
    TreeNode? t2 = x.right;

    // Perform rotation
    x.right = y;
    y.left = t2;

    // Update heights
    y.updateHeight();
    x.updateHeight();

    return x; // New root
  }

  /// Left rotation (RR case)
  TreeNode _rotateLeft(TreeNode x) {
    TreeNode y = x.right!;
    TreeNode? t2 = y.left;

    // Perform rotation
    y.left = x;
    x.right = t2;

    // Update heights
    x.updateHeight();
    y.updateHeight();

    return y; // New root
  }

  /// Insert a value into AVL tree
  TreeNode? insert(int val) {
    root = _insertNode(root, val);
    return root;
  }

  TreeNode _insertNode(TreeNode? node, int val) {
    // Standard BST insert
    if (node == null) {
      return TreeNode(value: val);
    }

    if (val < node.value) {
      node.left = _insertNode(node.left, val);
    } else if (val > node.value) {
      node.right = _insertNode(node.right, val);
    } else {
      return node; // Duplicate values not allowed
    }

    // Update height
    node.updateHeight();

    // Get balance factor
    int balance = _getBalance(node);

    // Left Left Case (LL)
    if (balance > 1 && val < node.left!.value) {
      return _rotateRight(node);
    }

    // Right Right Case (RR)
    if (balance < -1 && val > node.right!.value) {
      return _rotateLeft(node);
    }

    // Left Right Case (LR)
    if (balance > 1 && val > node.left!.value) {
      node.left = _rotateLeft(node.left!);
      return _rotateRight(node);
    }

    // Right Left Case (RL)
    if (balance < -1 && val < node.right!.value) {
      node.right = _rotateRight(node.right!);
      return _rotateLeft(node);
    }

    return node;
  }

  /// Clear the tree
  void clear() {
    root = null;
  }
}

/// Traversal types enum
enum TraversalType {
  inOrder('In-Order', 'Left → Root → Right'),
  preOrder('Pre-Order', 'Root → Left → Right'),
  postOrder('Post-Order', 'Left → Right → Root');

  final String title;
  final String description;
  const TraversalType(this.title, this.description);
}

/// Tree operation record for history
class TreeOperation {
  final String type; // 'insert', 'delete', 'search', 'traverse', 'rotate'
  final int? value;
  final String? rotationType; // 'LL', 'RR', 'LR', 'RL'
  final DateTime timestamp;

  TreeOperation({required this.type, this.value, this.rotationType})
    : timestamp = DateTime.now();

  @override
  String toString() => 'TreeOperation($type, value: $value)';
}
