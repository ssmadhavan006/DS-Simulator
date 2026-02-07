import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/sorting/sorting_algorithm.dart';
import '../models/sorting/bubble_sort.dart';
import '../models/sorting/selection_sort.dart';
import '../models/sorting/insertion_sort.dart';
import '../models/sorting/merge_sort.dart';
import '../models/sorting/quick_sort.dart';
import '../utils/constants.dart';

/// Animation states for sorting
enum SortingState { idle, sorting, paused, complete }

/// Sorting Provider for state management
class SortingProvider extends ChangeNotifier {
  // Available algorithms
  final List<SortingAlgorithm> algorithms = [
    BubbleSort(),
    SelectionSort(),
    InsertionSort(),
    MergeSort(),
    QuickSort(),
  ];

  // State
  List<int> _numbers = [];
  SortingAlgorithm _currentAlgorithm;
  SortingState _state = SortingState.idle;
  double _animationSpeed = AppConstants.speedDefault;
  int _arraySize = 20;

  // Animation tracking
  List<int> _comparingIndices = [];
  List<int> _swappingIndices = [];
  List<int> _sortedIndices = [];
  String? _statusMessage;
  String? _currentOperation;

  // Sorting iterator
  Iterator<SortingStep>? _sortingIterator;
  bool _shouldStop = false;

  SortingProvider() : _currentAlgorithm = BubbleSort() {
    generateRandom();
  }

  // Getters
  List<int> get numbers => List.unmodifiable(_numbers);
  SortingAlgorithm get currentAlgorithm => _currentAlgorithm;
  SortingState get state => _state;
  double get animationSpeed => _animationSpeed;
  int get arraySize => _arraySize;
  List<int> get comparingIndices => _comparingIndices;
  List<int> get swappingIndices => _swappingIndices;
  List<int> get sortedIndices => _sortedIndices;
  String? get statusMessage => _statusMessage;
  String? get currentOperation => _currentOperation;

  /// Set the sorting algorithm
  void setAlgorithm(SortingAlgorithm algorithm) {
    if (_state == SortingState.sorting) return;
    _currentAlgorithm = algorithm;
    _currentOperation = _getOperationName(algorithm);
    reset();
    notifyListeners();
  }

  /// Set array size and regenerate
  void setArraySize(int size) {
    if (_state == SortingState.sorting) return;
    _arraySize = size.clamp(5, 100);
    generateRandom();
  }

  /// Set animation speed
  void setSpeed(double speed) {
    _animationSpeed = speed.clamp(AppConstants.speedMin, AppConstants.speedMax);
    notifyListeners();
  }

  /// Generate random array
  void generateRandom() {
    final random = math.Random();
    _numbers = List.generate(_arraySize, (_) => random.nextInt(100) + 1);
    reset();
    _statusMessage = 'Generated $_arraySize random numbers';
    notifyListeners();
  }

  /// Start sorting animation
  Future<void> startSort() async {
    if (_state == SortingState.sorting) return;

    _state = SortingState.sorting;
    _shouldStop = false;
    _sortedIndices = [];
    _comparingIndices = [];
    _swappingIndices = [];
    _currentOperation = _getOperationName(_currentAlgorithm);
    notifyListeners();

    _sortingIterator = _currentAlgorithm.sort(_numbers).iterator;

    while (_sortingIterator!.moveNext() && !_shouldStop) {
      final step = _sortingIterator!.current;

      _numbers = List.from(step.array);
      _comparingIndices = step.comparingIndices;
      _swappingIndices = step.swappingIndices;
      _sortedIndices = step.sortedIndices;
      _statusMessage = step.description;
      notifyListeners();

      await Future.delayed(_getAnimationDuration());
    }

    if (!_shouldStop) {
      _state = SortingState.complete;
      _comparingIndices = [];
      _swappingIndices = [];
      _sortedIndices = List.generate(_numbers.length, (i) => i);
      _statusMessage = 'Sorting complete!';
      _currentOperation = null;
    }
    notifyListeners();
  }

  /// Pause sorting
  void pause() {
    if (_state != SortingState.sorting) return;
    _shouldStop = true;
    _state = SortingState.paused;
    notifyListeners();
  }

  /// Resume sorting
  Future<void> resume() async {
    if (_state != SortingState.paused || _sortingIterator == null) return;

    _state = SortingState.sorting;
    _shouldStop = false;
    notifyListeners();

    while (_sortingIterator!.moveNext() && !_shouldStop) {
      final step = _sortingIterator!.current;

      _numbers = List.from(step.array);
      _comparingIndices = step.comparingIndices;
      _swappingIndices = step.swappingIndices;
      _sortedIndices = step.sortedIndices;
      _statusMessage = step.description;
      notifyListeners();

      await Future.delayed(_getAnimationDuration());
    }

    if (!_shouldStop) {
      _state = SortingState.complete;
      _comparingIndices = [];
      _swappingIndices = [];
      _sortedIndices = List.generate(_numbers.length, (i) => i);
      _statusMessage = 'Sorting complete!';
      _currentOperation = null;
    }
    notifyListeners();
  }

  /// Reset to idle state
  void reset() {
    _shouldStop = true;
    _state = SortingState.idle;
    _comparingIndices = [];
    _swappingIndices = [];
    _sortedIndices = [];
    _sortingIterator = null;
    _statusMessage = null;
    _currentOperation = null;
    notifyListeners();
  }

  Duration _getAnimationDuration() {
    return Duration(
      milliseconds:
          (AppConstants.animationNormal.inMilliseconds / _animationSpeed)
              .round(),
    );
  }

  String _getOperationName(SortingAlgorithm algorithm) {
    if (algorithm is BubbleSort) return 'bubbleSort';
    if (algorithm is SelectionSort) return 'selectionSort';
    if (algorithm is InsertionSort) return 'insertionSort';
    if (algorithm is MergeSort) return 'mergeSort';
    if (algorithm is QuickSort) return 'quickSort';
    return 'sorting';
  }
}
