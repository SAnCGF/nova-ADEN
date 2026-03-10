class SuspendedSale {
  final String id;
  final List<Map<String, dynamic>> items;
  final double total;
  final String? customerName;
  final String? customerIdentity;
  final DateTime suspendedAt;
  final String? notes;

  SuspendedSale({
    required this.id,
    required this.items,
    required this.total,
    this.customerName,
    this.customerIdentity,
    DateTime? suspendedAt,
    this.notes,
  }) : suspendedAt = suspendedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items,
      'total': total,
      'customer_name': customerName,
      'customer_identity': customerIdentity,
      'suspended_at': suspendedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory SuspendedSale.fromMap(Map<String, dynamic> map) {
    return SuspendedSale(
      id: map['id'],
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      total: (map['total'] ?? 0).toDouble(),
      customerName: map['customer_name'],
      customerIdentity: map['customer_identity'],
      suspendedAt: map['suspended_at'] != null 
          ? DateTime.parse(map['suspended_at']) 
          : DateTime.now(),
      notes: map['notes'],
    );
  }
}
