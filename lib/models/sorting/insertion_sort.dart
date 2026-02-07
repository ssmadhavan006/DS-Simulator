import 'sorting_algorithm.dart';

/// Insertion Sort Algorithm
/// Time: O(n²) | Space: O(1) | Stable: Yes
class InsertionSort extends SortingAlgorithm {
  InsertionSort()
    : super(
        name: 'Insertion Sort',
        timeComplexityBest: 'O(n)',
        timeComplexityAverage: 'O(n²)',
        timeComplexityWorst: 'O(n²)',
        spaceComplexity: 'O(1)',
        isStable: true,
      );

  @override
  Iterable<SortingStep> sort(List<int> array) sync* {
    final arr = List<int>.from(array);
    final n = arr.length;
    final sorted = <int>[0]; // First element is sorted

    for (int i = 1; i < n; i++) {
      final key = arr[i];
      int j = i - 1;

      // Show key being inserted
      yield SortingStep(
        array: List.from(arr),
        comparingIndices: [i],
        sortedIndices: sorted,
        description: 'Inserting ${arr[i]} into sorted portion',
      );

      while (j >= 0 && arr[j] > key) {
        // Comparing
        yield SortingStep(
          array: List.from(arr),
          comparingIndices: [j, j + 1],
          sortedIndices: sorted,
          description: 'Comparing $key with ${arr[j]}',
        );

        // Shifting
        yield SortingStep(
          array: List.from(arr),
          swappingIndices: [j, j + 1],
          sortedIndices: sorted,
          description: 'Shifting ${arr[j]} right',
        );

        arr[j + 1] = arr[j];
        j--;
      }

      arr[j + 1] = key;
      sorted.add(i);
    }

    yield SortingStep(
      array: List.from(arr),
      sortedIndices: List.generate(n, (i) => i),
      description: 'Sorting complete!',
    );
  }
}
