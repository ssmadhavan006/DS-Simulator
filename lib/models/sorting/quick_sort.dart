import 'sorting_algorithm.dart';

/// Quick Sort Algorithm
/// Time: O(n log n) avg | Space: O(log n) | Stable: No
class QuickSort extends SortingAlgorithm {
  QuickSort()
    : super(
        name: 'Quick Sort',
        timeComplexityBest: 'O(n log n)',
        timeComplexityAverage: 'O(n log n)',
        timeComplexityWorst: 'O(n²)',
        spaceComplexity: 'O(log n)',
        isStable: false,
      );

  @override
  Iterable<SortingStep> sort(List<int> array) sync* {
    final arr = List<int>.from(array);
    final n = arr.length;
    final sorted = <int>[];

    yield* _quickSort(arr, 0, n - 1, sorted);

    yield SortingStep(
      array: List.from(arr),
      sortedIndices: List.generate(n, (i) => i),
      description: 'Sorting complete!',
    );
  }

  Iterable<SortingStep> _quickSort(
    List<int> arr,
    int low,
    int high,
    List<int> sorted,
  ) sync* {
    if (low < high) {
      // Partition
      int pivotIdx = low;
      final pivot = arr[high];

      yield SortingStep(
        array: List.from(arr),
        comparingIndices: [high],
        sortedIndices: sorted,
        description: 'Pivot: ${arr[high]} at index $high',
      );

      for (int j = low; j < high; j++) {
        yield SortingStep(
          array: List.from(arr),
          comparingIndices: [j, high],
          sortedIndices: sorted,
          description: 'Comparing ${arr[j]} with pivot $pivot',
        );

        if (arr[j] < pivot) {
          if (pivotIdx != j) {
            yield SortingStep(
              array: List.from(arr),
              swappingIndices: [pivotIdx, j],
              sortedIndices: sorted,
              description: 'Swapping ${arr[pivotIdx]} and ${arr[j]}',
            );

            final temp = arr[pivotIdx];
            arr[pivotIdx] = arr[j];
            arr[j] = temp;
          }
          pivotIdx++;
        }
      }

      // Place pivot in correct position
      yield SortingStep(
        array: List.from(arr),
        swappingIndices: [pivotIdx, high],
        sortedIndices: sorted,
        description: 'Placing pivot $pivot at position $pivotIdx',
      );

      final temp = arr[pivotIdx];
      arr[pivotIdx] = arr[high];
      arr[high] = temp;

      sorted.add(pivotIdx);

      // Recurse
      yield* _quickSort(arr, low, pivotIdx - 1, sorted);
      yield* _quickSort(arr, pivotIdx + 1, high, sorted);
    } else if (low == high && !sorted.contains(low)) {
      sorted.add(low);
    }
  }
}
