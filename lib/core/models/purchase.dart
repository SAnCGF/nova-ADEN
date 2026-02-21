class Purchase {
  final int? id;
  final String purchaseNumber;
  final DateTime date;
  final int? supplierId;
  final String? supplierName;
  final double subtotal;
  final double total;
  final String status; // 'pending', 'completed', 'cancelled'
  final DateTime createdAt;

  Purchase({
    this.id,
    required this.purchaseNumber,
    required this.date,
    this.supplierId,
    this.supplierName,
    required this.subtotal,
    required this.total,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_number': purchaseNumber,
      'date': date.toIso8601String(),
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'subtotal': subtotal,
      'total': total,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      id: map['id'],
      purchaseNumber: map['purchase_number'],
      date: DateTime.parse(map['date']),
      supplierId: map['supplier_id'],
      supplierName: map['supplier_name'],
      subtotal: map['subtotal'],
      total: map['total'],
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
