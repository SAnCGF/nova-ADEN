class StockAdjustment {
  final int? id;
  final int productId;
  final String productName;
  final int previousStock;
  final int newStock;
  final int difference;
  final String reason;
  final String? notes;
  final DateTime adjustedAt;

  StockAdjustment({
    this.id,
    required this.productId,
    required this.productName,
    required this.previousStock,
    required this.newStock,
    DateTime? adjustedAt,
    this.reason = 'Conteo físico',
    this.notes,
  }) : adjustedAt = adjustedAt ?? DateTime.now(),
       difference = newStock - previousStock;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'previous_stock': previousStock,
      'new_stock': newStock,
      'difference': difference,
      'reason': reason,
      'notes': notes,
      'adjusted_at': adjustedAt.toIso8601String(),
    };
  }

  factory StockAdjustment.fromMap(Map<String, dynamic> map) {
    return StockAdjustment(
      id: map['id'],
      productId: map['product_id'],
      productName: map['product_name'] ?? '',
      previousStock: map['previous_stock'] ?? 0,
      newStock: map['new_stock'] ?? 0,
      adjustedAt: map['adjusted_at'] != null 
          ? DateTime.parse(map['adjusted_at']) 
          : DateTime.now(),
      reason: map['reason'] ?? 'Conteo físico',
      notes: map['notes'],
    );
  }
}
