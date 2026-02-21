class Venta {
  final int? id;
  final String numeroVenta;
  final DateTime fecha;
  final double total;
  final double subtotal;
  final double impuesto;
  final double descuento;
  final String metodoPago;
  final String? cliente;
  final String? vendedor;
  final int estado;

  Venta({
    this.id,
    required this.numeroVenta,
    required this.fecha,
    required this.total,
    required this.subtotal,
    required this.impuesto,
    this.descuento = 0,
    this.metodoPago = 'EFECTIVO',
    this.cliente,
    this.vendedor,
    this.estado = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero_venta': numeroVenta,
      'fecha': fecha.toIso8601String(),
      'total': total,
      'subtotal': subtotal,
      'impuesto': impuesto,
      'descuento': descuento,
      'metodo_pago': metodoPago,
      'cliente': cliente,
      'vendedor': vendedor,
      'estado': estado,
    };
  }

  factory Venta.fromMap(Map<String, dynamic> map) {
    return Venta(
      id: map['id'],
      numeroVenta: map['numero_venta'],
      fecha: DateTime.parse(map['fecha']),
      total: map['total'],
      subtotal: map['subtotal'],
      impuesto: map['impuesto'],
      descuento: map['descuento'] ?? 0,
      metodoPago: map['metodo_pago'],
      cliente: map['cliente'],
      vendedor: map['vendedor'],
      estado: map['estado'],
    );
  }
}
