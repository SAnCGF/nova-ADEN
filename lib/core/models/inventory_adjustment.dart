class InventoryAdjustment {
  final int? id;
  final String adjustmentNumber;
  final DateTime date;
  final int productId;
  final String productName;
  final String productCode;
  final int quantityBefore;
  final int quantityAfter;
  final int adjustmentQuantity; // Positivo o negativo
  final String type; // 'positive' o 'negative'
  final String reason;
  final String? notes;
  final double unitCost;
  final double totalValue;
  final DateTime createdAt;

  InventoryAdjustment({
    this.id,
    required this.adjustmentNumber,
    required this.date,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.quantityBefore,
    required this.quantityAfter,
    required this.adjustmentQuantity,
    required this.type,
    required this.reason,
    this.notes,
    required this.unitCost,
    required this.totalValue,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adjustment_number': adjustmentNumber,
      'date': date.toIso8601String(),
      'product_id': productId,
      'product_name': productName,
      'product_code': productCode,
      'quantity_before': quantityBefore,
      'quantity_after': quantityAfter,
      'adjustment_quantity': adjustmentQuantity,
      'type': type,
      'reason': reason,
      'notes': notes,
      'unit_cost': unitCost,
      'total_value': totalValue,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory InventoryAdjustment.fromMap(Map<String, dynamic> map) {
    return InventoryAdjustment(
      id: map['id'],
      adjustmentNumber: map['adjustment_number'],
      date: DateTime.parse(map['date']),
      productId: map['product_id'],
      productName: map['product_name'],
      productCode: map['product_code'],
      quantityBefore: map['quantity_before'],
      quantityAfter: map['quantity_after'],
      adjustmentQuantity: map['adjustment_quantity'],
      type: map['type'],
      reason: map['reason'],
      notes: map['notes'],
      unitCost: map['unit_cost'],
      totalValue: map['total_value'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  bool get isPositive => type == 'positive';
  bool get isNegative => type == 'negative';
}
