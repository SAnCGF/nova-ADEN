import 'producto.dart';
import 'proveedor.dart';

class Compra {
  final int id;
  final Proveedor? proveedor;
  final DateTime fecha;
  final double total;

  Compra({
    required this.id,
    this.proveedor,
    required this.fecha,
    required this.total,
  });
}

class DetalleCompra {
  final int id;
  final int compraId;
  final Producto producto;
  final int cantidad;
  final double precioUnitario;

  DetalleCompra({
    required this.id,
    required this.compraId,
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
  });

  double get subtotal => cantidad * precioUnitario;
}