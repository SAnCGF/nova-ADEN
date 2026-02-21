class SaleItem {
  final int? id;
  final int? saleId;
  final int productId;
  final String productName;
  final String productCode;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  SaleItem({
    this.id,
    this.saleId,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'product_name': productName,
      'product_code': productCode,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['sale_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      productCode: map['product_code'],
      quantity: map['quantity'],
      unitPrice: map['unit_price'],
      subtotal: map['subtotal'],
    );
  }

  SaleItem copyWith({
    int? id,
    int? saleId,
    int? productId,
    String? productName,
    String? productCode,
    int? quantity,
    double? unitPrice,
    double? subtotal,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}
