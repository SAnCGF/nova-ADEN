class Sale {
  final int? id;
  final int? clienteId;
  final String fecha;
  final double total;
  final String estado;

  Sale({
    this.id,
    this.clienteId,
    required this.fecha,
    required this.total,
    this.estado = 'pagado',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'fecha': fecha,
      'total': total,
      'estado': estado,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      clienteId: map['cliente_id'],
      fecha: map['fecha'] ?? '',
      total: (map['total'] ?? 0).toDouble(),
      estado: map['estado'] ?? 'pagado',
    );
  }
}

class SaleLine {
  final int? id;
  final int ventaId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  SaleLine({
    this.id,
    required this.ventaId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'venta_id': ventaId,
      'producto_id': productoId,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
    };
  }

  factory SaleLine.fromMap(Map<String, dynamic> map) {
    return SaleLine(
      id: map['id'],
      ventaId: map['venta_id'] ?? 0,
      productoId: map['producto_id'] ?? 0,
      cantidad: map['cantidad'] ?? 0,
      precioUnitario: (map['precioUnitario'] ?? 0).toDouble(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
    );
  }
}

// Carrito de venta (temporal, no se guarda en BD)
class CartItem {
  final int productoId;
  final String nombre;
  final double precio;
  int cantidad;
  final int stockDisponible;

  CartItem({
    required this.productoId,
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.stockDisponible,
  });

  double get subtotal => precio * cantidad;
}
