import 'node.dart';
import '../utils/constants.dart';

/// Queue Data Structure Model
/// FIFO - First In First Out
class QueueModel {
  final List<Node> _items = [];
  final int maxSize;
  final bool isCircular;

  QueueModel({
    this.maxSize = AppConstants.maxQueueSize,
    this.isCircular = false,
  });

  /// Get all items (read-only)
  List<Node> get items => List.unmodifiable(_items);

  /// Current size of the queue
  int get size => _items.length;

  /// Check if queue is empty
  bool get isEmpty => _items.isEmpty;

  /// Check if queue is full
  bool get isFull => _items.length >= maxSize;

  /// Get front element without removing
  Node? get front => _items.isNotEmpty ? _items.first : null;

  /// Get rear element without removing
  Node? get rear => _items.isNotEmpty ? _items.last : null;

  /// Front index for circular queue visualization
  int get frontIndex => 0;

  /// Rear index for circular queue visualization
  int get rearIndex => _items.isEmpty ? -1 : _items.length - 1;

  /// Enqueue a new value at the rear
  /// Returns the newly created node, or null if queue is full
  Node? enqueue(int value) {
    if (isFull) return null;
    final node = Node(value: value);
    _items.add(node);
    return node;
  }

  /// Dequeue the front element
  /// Returns the removed node, or null if queue is empty
  Node? dequeue() {
    if (isEmpty) return null;
    return _items.removeAt(0);
  }

  /// Peek at the front element
  /// Returns the front node without removing it
  Node? peek() => front;

  /// Clear all items
  void clear() => _items.clear();

  /// Get item at specific index (0 = front, size-1 = rear)
  Node? getAt(int index) {
    if (index < 0 || index >= _items.length) return null;
    return _items[index];
  }

  /// Get circular index for visualization
  int getCircularIndex(int index) {
    if (maxSize == 0) return 0;
    return index % maxSize;
  }

  @override
  String toString() =>
      'Queue(size: $size, items: $_items, circular: $isCircular)';
}

/// Operation record for history/undo
class QueueOperation {
  final String type; // 'enqueue', 'dequeue', 'peek', 'clear'
  final Node? node;
  final DateTime timestamp;

  QueueOperation({required this.type, this.node}) : timestamp = DateTime.now();

  @override
  String toString() => 'QueueOperation($type, node: $node)';
}
