import 'sorting_algorithm.dart';

/// Bubble Sort Algorithm
/// Time: O(n²) | Space: O(1) | Stable: Yes
class BubbleSort extends SortingAlgorithm {
  BubbleSort()
    : super(
        name: 'Bubble Sort',
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
    final sorted = <int>[];

    for (int i = 0; i < n - 1; i++) {
      bool swapped = false;

      for (int j = 0; j < n - i - 1; j++) {
        // Comparing
        yield SortingStep(
          array: List.from(arr),
          comparingIndices: [j, j + 1],
          sortedIndices: sorted,
          description: 'Comparing ${arr[j]} and ${arr[j + 1]}',
        );

        if (arr[j] > arr[j + 1]) {
          // Swapping
          yield SortingStep(
            array: List.from(arr),
            swappingIndices: [j, j + 1],
            sortedIndices: sorted,
            description: 'Swapping ${arr[j]} and ${arr[j + 1]}',
          );

          final temp = arr[j];
          arr[j] = arr[j + 1];
          arr[j + 1] = temp;
          swapped = true;
        }
      }

      sorted.insert(0, n - i - 1);

      if (!swapped) {
        // Already sorted
        for (int k = 0; k < n - i - 1; k++) {
          sorted.insert(0, k);
        }
        break;
      }
    }

    if (!sorted.contains(0)) sorted.insert(0, 0);

    yield SortingStep(
      array: List.from(arr),
      sortedIndices: List.generate(n, (i) => i),
      description: 'Sorting complete!',
    );
  }
}
