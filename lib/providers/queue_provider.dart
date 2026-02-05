import 'package:flutter/material.dart';
import '../models/queue_model.dart';
import '../models/node.dart';
import '../utils/constants.dart';

/// Queue Provider for state management and animations
class QueueProvider extends ChangeNotifier {
  QueueModel _queue = QueueModel();
  final List<QueueOperation> _history = [];

  // Animation state
  AnimationState _animationState = AnimationState.idle;
  double _animationSpeed = AppConstants.speedDefault;
  Node? _animatingNode;
  String? _currentOperation;
  String? _statusMessage;
  bool _isCircularMode = false;

  // Getters
  QueueModel get queue => _queue;
  List<Node> get items => _queue.items;
  int get size => _queue.size;
  bool get isEmpty => _queue.isEmpty;
  bool get isFull => _queue.isFull;
  Node? get front => _queue.front;
  Node? get rear => _queue.rear;
  List<QueueOperation> get history => List.unmodifiable(_history);
  bool get isCircularMode => _isCircularMode;

  AnimationState get animationState => _animationState;
  double get animationSpeed => _animationSpeed;
  Node? get animatingNode => _animatingNode;
  String? get currentOperation => _currentOperation;
  String? get statusMessage => _statusMessage;

  // Animation duration based on speed
  Duration get animationDuration => Duration(
    milliseconds:
        (AppConstants.animationNormal.inMilliseconds / _animationSpeed).round(),
  );

  /// Toggle circular queue mode
  void toggleCircularMode() {
    _isCircularMode = !_isCircularMode;
    _queue = QueueModel(isCircular: _isCircularMode);
    _statusMessage =
        'Switched to ${_isCircularMode ? "Circular" : "Linear"} Queue';
    notifyListeners();
  }

  /// Enqueue a value with animation
  Future<bool> enqueue(int value) async {
    if (_queue.isFull) {
      _statusMessage =
          'Queue Overflow! Maximum size (${_queue.maxSize}) reached.';
      notifyListeners();
      return false;
    }

    _currentOperation = 'enqueue';
    _animationState = AnimationState.playing;
    notifyListeners();

    final node = _queue.enqueue(value);
    if (node != null) {
      _animatingNode = node;
      _history.add(QueueOperation(type: 'enqueue', node: node));
      _statusMessage = 'Enqueued $value at the rear';
      notifyListeners();

      // Wait for animation
      await Future.delayed(animationDuration);

      _animatingNode = null;
      _animationState = AnimationState.idle;
      _currentOperation = null;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Dequeue the front value with animation
  Future<Node?> dequeue() async {
    if (_queue.isEmpty) {
      _statusMessage = 'Queue Underflow! Queue is empty.';
      notifyListeners();
      return null;
    }

    _currentOperation = 'dequeue';
    _animationState = AnimationState.playing;
    _animatingNode = _queue.front;
    notifyListeners();

    // Wait for animation to start
    await Future.delayed(animationDuration);

    final node = _queue.dequeue();
    if (node != null) {
      _history.add(QueueOperation(type: 'dequeue', node: node));
      _statusMessage = 'Dequeued ${node.value} from the front';
    }

    _animatingNode = null;
    _animationState = AnimationState.idle;
    _currentOperation = null;
    notifyListeners();
    return node;
  }

  /// Peek at the front value (highlight without removing)
  Future<Node?> peek() async {
    if (_queue.isEmpty) {
      _statusMessage = 'Queue is empty. Nothing to peek.';
      notifyListeners();
      return null;
    }

    _currentOperation = 'peek';
    _animationState = AnimationState.playing;
    _animatingNode = _queue.front;
    _history.add(QueueOperation(type: 'peek', node: _queue.front));
    _statusMessage = 'Front element is ${_queue.front?.value}';
    notifyListeners();

    // Wait for highlight animation
    await Future.delayed(animationDuration);

    _animatingNode = null;
    _animationState = AnimationState.idle;
    _currentOperation = null;
    notifyListeners();
    return _queue.front;
  }

  /// Clear the queue
  void clear() {
    _queue = QueueModel(isCircular: _isCircularMode);
    _history.add(QueueOperation(type: 'clear'));
    _statusMessage = 'Queue cleared';
    _animatingNode = null;
    _animationState = AnimationState.idle;
    _currentOperation = null;
    notifyListeners();
  }

  /// Set animation speed
  void setSpeed(double speed) {
    _animationSpeed = speed.clamp(AppConstants.speedMin, AppConstants.speedMax);
    notifyListeners();
  }

  /// Generate random data
  Future<void> generateRandom(int count) async {
    clear();
    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < count && !_queue.isFull; i++) {
      await enqueue((random + i * 17) % 100);
    }
  }

  /// Clear status message
  void clearStatus() {
    _statusMessage = null;
    notifyListeners();
  }
}

/// Animation state enum
enum AnimationState { idle, playing, paused, stepping }
