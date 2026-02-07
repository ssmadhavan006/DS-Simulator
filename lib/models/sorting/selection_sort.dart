import 'sorting_algorithm.dart';

/// Selection Sort Algorithm
/// Time: O(n²) | Space: O(1) | Stable: No
class SelectionSort extends SortingAlgorithm {
  SelectionSort()
    : super(
        name: 'Selection Sort',
        timeComplexityBest: 'O(n²)',
        timeComplexityAverage: 'O(n²)',
        timeComplexityWorst: 'O(n²)',
        spaceComplexity: 'O(1)',
        isStable: false,
      );

  @override
  Iterable<SortingStep> sort(List<int> array) sync* {
    final arr = List<int>.from(array);
    final n = arr.length;
    final sorted = <int>[];

    for (int i = 0; i < n - 1; i++) {
      int minIdx = i;

      for (int j = i + 1; j < n; j++) {
        // Comparing
        yield SortingStep(
          array: List.from(arr),
          comparingIndices: [minIdx, j],
          sortedIndices: sorted,
          description:
              'Finding minimum: comparing ${arr[minIdx]} and ${arr[j]}',
        );

        if (arr[j] < arr[minIdx]) {
          minIdx = j;
        }
      }

      if (minIdx != i) {
        // Swapping
        yield SortingStep(
          array: List.from(arr),
          swappingIndices: [i, minIdx],
          sortedIndices: sorted,
          description: 'Swapping ${arr[i]} with minimum ${arr[minIdx]}',
        );

        final temp = arr[i];
        arr[i] = arr[minIdx];
        arr[minIdx] = temp;
      }

      sorted.add(i);
    }

    sorted.add(n - 1);

    yield SortingStep(
      array: List.from(arr),
      sortedIndices: List.generate(n, (i) => i),
      description: 'Sorting complete!',
    );
  }
}
