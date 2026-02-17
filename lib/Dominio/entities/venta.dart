import 'producto.dart';

class Venta {
  final int id;
  final DateTime fecha;
  final double total;

  Venta({
    required this.id,
    required this.fecha,
    required this.total,
  });
}

class DetalleVenta {
  final int id;
  final int ventaId;
  final Producto producto;
  final int cantidad;
  final double precioUnitario;

  DetalleVenta({
    required this.id,
    required this.ventaId,
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
  });

  double get subtotal => cantidad * precioUnitario;
}