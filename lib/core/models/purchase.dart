class Purchase {
  final int? id;
  final int? proveedorId;
  final String fecha;
  final double total;
  final String estado;

  Purchase({
    this.id,
    this.proveedorId,
    required this.fecha,
    required this.total,
    this.estado = 'pendiente',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'proveedor_id': proveedorId,
      'fecha': fecha,
      'total': total,
      'estado': estado,
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      id: map['id'],
      proveedorId: map['proveedor_id'],
      fecha: map['fecha'] ?? '',
      total: (map['total'] ?? 0).toDouble(),
      estado: map['estado'] ?? 'pendiente',
    );
  }
}

class PurchaseLine {
  final int? id;
  final int compraId;
  final int productoId;
  final int cantidad;
  final double costoUnitario;
  final double subtotal;

  PurchaseLine({
    this.id,
    required this.compraId,
    required this.productoId,
    required this.cantidad,
    required this.costoUnitario,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'compra_id': compraId,
      'producto_id': productoId,
      'cantidad': cantidad,
      'costoUnitario': costoUnitario,
      'subtotal': subtotal,
    };
  }

  factory PurchaseLine.fromMap(Map<String, dynamic> map) {
    return PurchaseLine(
      id: map['id'],
      compraId: map['compra_id'] ?? 0,
      productoId: map['producto_id'] ?? 0,
      cantidad: map['cantidad'] ?? 0,
      costoUnitario: (map['costoUnitario'] ?? 0).toDouble(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
    );
  }
}
