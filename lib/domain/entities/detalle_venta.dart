class DetalleVenta {
  final int? id;
  final int ventaId;
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final double descuento;
  final double total;

  DetalleVenta({
    this.id,
    required this.ventaId,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    this.descuento = 0,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'venta_id': ventaId,
      'producto_id': productoId,
      'nombre_producto': nombreProducto,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'subtotal': subtotal,
      'descuento': descuento,
      'total': total,
    };
  }

  factory DetalleVenta.fromMap(Map<String, dynamic> map) {
    return DetalleVenta(
      id: map['id'],
      ventaId: map['venta_id'],
      productoId: map['producto_id'],
      nombreProducto: map['nombre_producto'],
      cantidad: map['cantidad'],
      precioUnitario: map['precio_unitario'],
      subtotal: map['subtotal'],
      descuento: map['descuento'] ?? 0,
      total: map['total'],
    );
  }
}
