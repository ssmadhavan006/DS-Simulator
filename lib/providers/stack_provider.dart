import 'package:flutter/material.dart';
import '../models/stack_model.dart';
import '../models/node.dart';
import '../utils/constants.dart';

/// Stack Provider for state management and animations
class StackProvider extends ChangeNotifier {
  final StackModel _stack = StackModel();
  final List<StackOperation> _history = [];

  // Animation state
  AnimationState _animationState = AnimationState.idle;
  double _animationSpeed = AppConstants.speedDefault;
  Node? _animatingNode;
  String? _currentOperation;
  String? _statusMessage;

  // Getters
  StackModel get stack => _stack;
  List<Node> get items => _stack.items;
  int get size => _stack.size;
  bool get isEmpty => _stack.isEmpty;
  bool get isFull => _stack.isFull;
  Node? get top => _stack.top;
  List<StackOperation> get history => List.unmodifiable(_history);

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

  /// Push a value onto the stack with animation
  Future<bool> push(int value) async {
    if (_stack.isFull) {
      _statusMessage =
          'Stack Overflow! Maximum size (${_stack.maxSize}) reached.';
      notifyListeners();
      return false;
    }

    _currentOperation = 'push';
    _animationState = AnimationState.playing;
    notifyListeners();

    final node = _stack.push(value);
    if (node != null) {
      _animatingNode = node;
      _history.add(StackOperation(type: 'push', node: node));
      _statusMessage = 'Pushed $value onto the stack';
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

  /// Pop the top value from the stack with animation
  Future<Node?> pop() async {
    if (_stack.isEmpty) {
      _statusMessage = 'Stack Underflow! Stack is empty.';
      notifyListeners();
      return null;
    }

    _currentOperation = 'pop';
    _animationState = AnimationState.playing;
    _animatingNode = _stack.top;
    notifyListeners();

    // Wait for animation to start
    await Future.delayed(animationDuration);

    final node = _stack.pop();
    if (node != null) {
      _history.add(StackOperation(type: 'pop', node: node));
      _statusMessage = 'Popped ${node.value} from the stack';
    }

    _animatingNode = null;
    _animationState = AnimationState.idle;
    _currentOperation = null;
    notifyListeners();
    return node;
  }

  /// Peek at the top value (highlight without removing)
  Future<Node?> peek() async {
    if (_stack.isEmpty) {
      _statusMessage = 'Stack is empty. Nothing to peek.';
      notifyListeners();
      return null;
    }

    _currentOperation = 'peek';
    _animationState = AnimationState.playing;
    _animatingNode = _stack.top;
    _history.add(StackOperation(type: 'peek', node: _stack.top));
    _statusMessage = 'Top element is ${_stack.top?.value}';
    notifyListeners();

    // Wait for highlight animation
    await Future.delayed(animationDuration);

    _animatingNode = null;
    _animationState = AnimationState.idle;
    _currentOperation = null;
    notifyListeners();
    return _stack.top;
  }

  /// Clear the stack
  void clear() {
    _stack.clear();
    _history.add(StackOperation(type: 'clear'));
    _statusMessage = 'Stack cleared';
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
    for (int i = 0; i < count && !_stack.isFull; i++) {
      await push((random + i * 17) % 100);
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
