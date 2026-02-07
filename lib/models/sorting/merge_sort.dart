import 'sorting_algorithm.dart';

/// Merge Sort Algorithm
/// Time: O(n log n) | Space: O(n) | Stable: Yes
class MergeSort extends SortingAlgorithm {
  MergeSort()
    : super(
        name: 'Merge Sort',
        timeComplexityBest: 'O(n log n)',
        timeComplexityAverage: 'O(n log n)',
        timeComplexityWorst: 'O(n log n)',
        spaceComplexity: 'O(n)',
        isStable: true,
      );

  @override
  Iterable<SortingStep> sort(List<int> array) sync* {
    final arr = List<int>.from(array);
    final n = arr.length;

    yield* _mergeSort(arr, 0, n - 1, <int>[]);

    yield SortingStep(
      array: List.from(arr),
      sortedIndices: List.generate(n, (i) => i),
      description: 'Sorting complete!',
    );
  }

  Iterable<SortingStep> _mergeSort(
    List<int> arr,
    int left,
    int right,
    List<int> sorted,
  ) sync* {
    if (left < right) {
      final mid = left + (right - left) ~/ 2;

      // Divide
      yield SortingStep(
        array: List.from(arr),
        comparingIndices: List.generate(mid - left + 1, (i) => left + i),
        sortedIndices: sorted,
        description: 'Dividing: left half [$left-$mid]',
      );

      yield* _mergeSort(arr, left, mid, sorted);

      yield SortingStep(
        array: List.from(arr),
        comparingIndices: List.generate(right - mid, (i) => mid + 1 + i),
        sortedIndices: sorted,
        description: 'Dividing: right half [${mid + 1}-$right]',
      );

      yield* _mergeSort(arr, mid + 1, right, sorted);

      // Merge
      yield* _merge(arr, left, mid, right, sorted);
    }
  }

  Iterable<SortingStep> _merge(
    List<int> arr,
    int left,
    int mid,
    int right,
    List<int> sorted,
  ) sync* {
    final leftArr = arr.sublist(left, mid + 1);
    final rightArr = arr.sublist(mid + 1, right + 1);

    int i = 0, j = 0, k = left;

    yield SortingStep(
      array: List.from(arr),
      comparingIndices: List.generate(right - left + 1, (idx) => left + idx),
      sortedIndices: sorted,
      description: 'Merging [$left-$mid] and [${mid + 1}-$right]',
    );

    while (i < leftArr.length && j < rightArr.length) {
      yield SortingStep(
        array: List.from(arr),
        comparingIndices: [left + i, mid + 1 + j],
        sortedIndices: sorted,
        description: 'Comparing ${leftArr[i]} and ${rightArr[j]}',
      );

      if (leftArr[i] <= rightArr[j]) {
        arr[k] = leftArr[i];
        i++;
      } else {
        arr[k] = rightArr[j];
        j++;
      }

      yield SortingStep(
        array: List.from(arr),
        swappingIndices: [k],
        sortedIndices: sorted,
        description: 'Placing ${arr[k]} at position $k',
      );

      k++;
    }

    while (i < leftArr.length) {
      arr[k] = leftArr[i];
      yield SortingStep(
        array: List.from(arr),
        swappingIndices: [k],
        sortedIndices: sorted,
        description: 'Placing remaining ${arr[k]}',
      );
      i++;
      k++;
    }

    while (j < rightArr.length) {
      arr[k] = rightArr[j];
      yield SortingStep(
        array: List.from(arr),
        swappingIndices: [k],
        sortedIndices: sorted,
        description: 'Placing remaining ${arr[k]}',
      );
      j++;
      k++;
    }
  }
}
