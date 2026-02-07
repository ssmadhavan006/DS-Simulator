/// Code snippets for DSA operations
/// Used in CodePreview widget for educational display
class CodeSnippets {
  // Prevent instantiation
  CodeSnippets._();

  // Stack Operations
  static const String stackPush = '''
void push(T item) {
  if (isFull()) {
    throw StackOverflowError();
  }
  items[++top] = item;  // ← Current step
}
''';

  static const String stackPop = '''
T pop() {
  if (isEmpty()) {
    throw StackUnderflowError();
  }
  return items[top--];  // ← Current step
}
''';

  static const String stackPeek = '''
T peek() {
  if (isEmpty()) {
    throw EmptyStackError();
  }
  return items[top];  // ← Just reading, no modification
}
''';

  // Queue Operations
  static const String queueEnqueue = '''
void enqueue(T item) {
  if (isFull()) {
    throw QueueOverflowError();
  }
  rear = (rear + 1) % capacity;
  items[rear] = item;  // ← Add to rear
  size++;
}
''';

  static const String queueDequeue = '''
T dequeue() {
  if (isEmpty()) {
    throw QueueUnderflowError();
  }
  T item = items[front];  // ← Remove from front
  front = (front + 1) % capacity;
  size--;
  return item;
}
''';

  // BST Operations
  static const String bstInsert = '''
Node insert(Node node, int value) {
  if (node == null) {
    return Node(value);  // ← Create new node
  }
  if (value < node.value) {
    node.left = insert(node.left, value);
  } else {
    node.right = insert(node.right, value);
  }
  return node;
}
''';

  static const String bstSearch = '''
Node search(Node node, int value) {
  if (node == null || node.value == value) {
    return node;  // ← Found or not found
  }
  if (value < node.value) {
    return search(node.left, value);
  }
  return search(node.right, value);
}
''';

  static const String inOrderTraversal = '''
void inOrder(Node node) {
  if (node == null) return;
  
  inOrder(node.left);   // ← Visit left subtree
  visit(node);          // ← Visit root
  inOrder(node.right);  // ← Visit right subtree
}
''';

  static const String preOrderTraversal = '''
void preOrder(Node node) {
  if (node == null) return;
  
  visit(node);           // ← Visit root first
  preOrder(node.left);   // ← Then left subtree
  preOrder(node.right);  // ← Then right subtree
}
''';

  static const String postOrderTraversal = '''
void postOrder(Node node) {
  if (node == null) return;
  
  postOrder(node.left);   // ← Visit left subtree
  postOrder(node.right);  // ← Visit right subtree
  visit(node);            // ← Visit root last
}
''';

  // Graph Algorithms
  static const String bfs = '''
void bfs(Node start) {
  Queue<Node> queue = new Queue();
  Set<Node> visited = new Set();
  
  queue.enqueue(start);
  visited.add(start);
  
  while (!queue.isEmpty()) {
    Node current = queue.dequeue();  // ← Process node
    print(current);
    
    for (Node neighbor : current.neighbors) {
      if (!visited.contains(neighbor)) {
        visited.add(neighbor);
        queue.enqueue(neighbor);  // ← Add to queue
      }
    }
  }
}
''';

  static const String dfs = '''
void dfs(Node node, Set<Node> visited) {
  if (visited.contains(node)) return;
  
  visited.add(node);
  print(node);  // ← Process node
  
  for (Node neighbor : node.neighbors) {
    dfs(neighbor, visited);  // ← Recursive call
  }
}
''';

  static const String dijkstra = '''
void dijkstra(Node start) {
  Map<Node, int> dist = {};
  PriorityQueue<Node> pq = new PriorityQueue();
  
  dist[start] = 0;
  pq.add(start);
  
  while (!pq.isEmpty()) {
    Node u = pq.extractMin();  // ← Get closest
    
    for (Edge e : u.edges) {
      Node v = e.target;
      int alt = dist[u] + e.weight;
      
      if (alt < dist[v]) {
        dist[v] = alt;  // ← Relax edge
        pq.decreaseKey(v, alt);
      }
    }
  }
}
''';

  // AVL Rotations
  static const String avlRotateRight = '''
Node rotateRight(Node y) {
  Node x = y.left;
  Node T2 = x.right;
  
  x.right = y;  // ← Perform rotation
  y.left = T2;
  
  updateHeight(y);
  updateHeight(x);
  
  return x;  // ← New root
}
''';

  static const String avlRotateLeft = '''
Node rotateLeft(Node x) {
  Node y = x.right;
  Node T2 = y.left;
  
  y.left = x;  // ← Perform rotation
  x.right = T2;
  
  updateHeight(x);
  updateHeight(y);
  
  return y;  // ← New root
}
''';

  // Sorting Algorithms
  static const String bubbleSort = '''
void bubbleSort(int[] arr) {
  int n = arr.length;
  for (int i = 0; i < n - 1; i++) {
    for (int j = 0; j < n - i - 1; j++) {
      if (arr[j] > arr[j + 1]) {
        swap(arr[j], arr[j + 1]);  // ← Swap
      }
    }
  }
}
''';

  static const String selectionSort = '''
void selectionSort(int[] arr) {
  int n = arr.length;
  for (int i = 0; i < n - 1; i++) {
    int minIdx = i;
    for (int j = i + 1; j < n; j++) {
      if (arr[j] < arr[minIdx]) {
        minIdx = j;  // ← Find minimum
      }
    }
    swap(arr[i], arr[minIdx]);
  }
}
''';

  static const String insertionSort = '''
void insertionSort(int[] arr) {
  for (int i = 1; i < arr.length; i++) {
    int key = arr[i];
    int j = i - 1;
    while (j >= 0 && arr[j] > key) {
      arr[j + 1] = arr[j];  // ← Shift right
      j--;
    }
    arr[j + 1] = key;  // ← Insert
  }
}
''';

  static const String mergeSort = '''
void mergeSort(int[] arr, int l, int r) {
  if (l < r) {
    int m = l + (r - l) / 2;
    mergeSort(arr, l, m);      // ← Left half
    mergeSort(arr, m + 1, r);  // ← Right half
    merge(arr, l, m, r);       // ← Merge
  }
}
''';

  static const String quickSort = '''
void quickSort(int[] arr, int low, int high) {
  if (low < high) {
    int pi = partition(arr, low, high);
    quickSort(arr, low, pi - 1);   // ← Left of pivot
    quickSort(arr, pi + 1, high);  // ← Right of pivot
  }
}
int partition(int[] arr, int low, int high) {
  int pivot = arr[high];  // ← Pivot element
  int i = low - 1;
  for (int j = low; j < high; j++) {
    if (arr[j] < pivot) {
      i++;
      swap(arr[i], arr[j]);
    }
  }
  swap(arr[i + 1], arr[high]);
  return i + 1;
}
''';

  /// Get snippet by operation name
  static String getSnippet(String operation) {
    switch (operation) {
      case 'push':
        return stackPush;
      case 'pop':
        return stackPop;
      case 'peek':
        return stackPeek;
      case 'enqueue':
        return queueEnqueue;
      case 'dequeue':
        return queueDequeue;
      case 'insert_bst':
        return bstInsert;
      case 'search_bst':
        return bstSearch;
      case 'inOrder':
        return inOrderTraversal;
      case 'preOrder':
        return preOrderTraversal;
      case 'postOrder':
        return postOrderTraversal;
      case 'bfs':
        return bfs;
      case 'dfs':
        return dfs;
      case 'dijkstra':
        return dijkstra;
      case 'rotateRight':
        return avlRotateRight;
      case 'rotateLeft':
        return avlRotateLeft;
      case 'bubbleSort':
        return bubbleSort;
      case 'selectionSort':
        return selectionSort;
      case 'insertionSort':
        return insertionSort;
      case 'mergeSort':
        return mergeSort;
      case 'quickSort':
        return quickSort;
      default:
        return '// No code snippet available for "$operation"';
    }
  }
}
