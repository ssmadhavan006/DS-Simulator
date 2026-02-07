/// Represents a single step in the sorting animation
class SortingStep {
  final List<int> array;
  final List<int> comparingIndices;
  final List<int> swappingIndices;
  final List<int> sortedIndices;
  final String description;

  SortingStep({
    required this.array,
    this.comparingIndices = const [],
    this.swappingIndices = const [],
    this.sortedIndices = const [],
    this.description = '',
  });

  SortingStep copyWith({
    List<int>? array,
    List<int>? comparingIndices,
    List<int>? swappingIndices,
    List<int>? sortedIndices,
    String? description,
  }) {
    return SortingStep(
      array: array ?? List.from(this.array),
      comparingIndices: comparingIndices ?? this.comparingIndices,
      swappingIndices: swappingIndices ?? this.swappingIndices,
      sortedIndices: sortedIndices ?? this.sortedIndices,
      description: description ?? this.description,
    );
  }
}

/// Abstract base class for sorting algorithms
abstract class SortingAlgorithm {
  final String name;
  final String timeComplexityBest;
  final String timeComplexityAverage;
  final String timeComplexityWorst;
  final String spaceComplexity;
  final bool isStable;

  SortingAlgorithm({
    required this.name,
    required this.timeComplexityBest,
    required this.timeComplexityAverage,
    required this.timeComplexityWorst,
    required this.spaceComplexity,
    required this.isStable,
  });

  /// Generate sorting steps for animation
  /// Yields SortingStep objects for each comparison/swap
  Iterable<SortingStep> sort(List<int> array);
}
