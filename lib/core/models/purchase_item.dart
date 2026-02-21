class PurchaseItem {
  final int? id;
  final int? purchaseId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitCost;
  final double subtotal;

  PurchaseItem({
    this.id,
    this.purchaseId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitCost,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_cost': unitCost,
      'subtotal': subtotal,
    };
  }

  factory PurchaseItem.fromMap(Map<String, dynamic> map) {
    return PurchaseItem(
      id: map['id'],
      purchaseId: map['purchase_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      quantity: map['quantity'],
      unitCost: map['unit_cost'],
      subtotal: map['subtotal'],
    );
  }

  PurchaseItem copyWith({
    int? id,
    int? purchaseId,
    int? productId,
    String? productName,
    int? quantity,
    double? unitCost,
    double? subtotal,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}
