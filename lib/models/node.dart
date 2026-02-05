/// Base Node model for all data structures
class Node {
  final String id;
  final int value;
  final DateTime createdAt;

  Node({required this.value, String? id})
    : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt = DateTime.now();

  Node copyWith({String? id, int? value}) {
    return Node(id: id ?? this.id, value: value ?? this.value);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Node && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Node(id: $id, value: $value)';
}
