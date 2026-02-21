class InventoryLoss {
  final int? id;
  final String lossNumber;
  final DateTime date;
  final int productId;
  final String productName;
  final String productCode;
  final int quantity;
  final double unitCost;
  final double totalValue;
  final String reasonId;
  final String reasonName;
  final String? notes;
  final DateTime createdAt;

  InventoryLoss({
    this.id,
    required this.lossNumber,
    required this.date,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.quantity,
    required this.unitCost,
    required this.totalValue,
    required this.reasonId,
    required this.reasonName,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loss_number': lossNumber,
      'date': date.toIso8601String(),
      'product_id': productId,
      'product_name': productName,
      'product_code': productCode,
      'quantity': quantity,
      'unit_cost': unitCost,
      'total_value': totalValue,
      'reason_id': reasonId,
      'reason_name': reasonName,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory InventoryLoss.fromMap(Map<String, dynamic> map) {
    return InventoryLoss(
      id: map['id'],
      lossNumber: map['loss_number'],
      date: DateTime.parse(map['date']),
      productId: map['product_id'],
      productName: map['product_name'],
      productCode: map['product_code'],
      quantity: map['quantity'],
      unitCost: map['unit_cost'],
      totalValue: map['total_value'],
      reasonId: map['reason_id'],
      reasonName: map['reason_name'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
