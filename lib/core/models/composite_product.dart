class CompositeProduct {
  final int? id;
  final int parentId;
  final int childId;
  final int quantity;
  final DateTime createdAt;

  CompositeProduct({
    this.id,
    required this.parentId,
    required this.childId,
    required this.quantity,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'child_id': childId,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CompositeProduct.fromMap(Map<String, dynamic> map) {
    return CompositeProduct(
      id: map['id'],
      parentId: map['parent_id'],
      childId: map['child_id'],
      quantity: map['quantity'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }
}
