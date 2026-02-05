import 'node.dart';
import '../utils/constants.dart';

/// Stack Data Structure Model
/// LIFO - Last In First Out
class StackModel {
  final List<Node> _items = [];
  final int maxSize;

  StackModel({this.maxSize = AppConstants.maxStackSize});

  /// Get all items (read-only)
  List<Node> get items => List.unmodifiable(_items);

  /// Current size of the stack
  int get size => _items.length;

  /// Check if stack is empty
  bool get isEmpty => _items.isEmpty;

  /// Check if stack is full
  bool get isFull => _items.length >= maxSize;

  /// Get top element without removing
  Node? get top => _items.isNotEmpty ? _items.last : null;

  /// Push a new value onto the stack
  /// Returns the newly created node, or null if stack is full
  Node? push(int value) {
    if (isFull) return null;
    final node = Node(value: value);
    _items.add(node);
    return node;
  }

  /// Pop the top element
  /// Returns the removed node, or null if stack is empty
  Node? pop() {
    if (isEmpty) return null;
    return _items.removeLast();
  }

  /// Peek at the top element
  /// Returns the top node without removing it
  Node? peek() => top;

  /// Clear all items
  void clear() => _items.clear();

  /// Get item at specific index (0 = bottom, size-1 = top)
  Node? getAt(int index) {
    if (index < 0 || index >= _items.length) return null;
    return _items[index];
  }

  @override
  String toString() => 'Stack(size: $size, items: $_items)';
}

/// Operation record for history/undo
class StackOperation {
  final String type; // 'push', 'pop', 'peek', 'clear'
  final Node? node;
  final DateTime timestamp;

  StackOperation({required this.type, this.node}) : timestamp = DateTime.now();

  @override
  String toString() => 'StackOperation($type, node: $node)';
}
