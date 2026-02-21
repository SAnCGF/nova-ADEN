import 'package:flutter/foundation.dart';
import '../../domain/repositories/venta_repository.dart';

class CartItem {
  final int productoId;
  final String nombre;
  final double precio;
  int cantidad;
  final double stock;

  CartItem({
    required this.productoId,
    required this.nombre,
    required this.precio,
    this.cantidad = 1,
    this.stock = 0,
  });

  double get subtotal => precio * cantidad;
}

class VentaBloc extends ChangeNotifier {
  final VentaRepository repository;
  
  List<CartItem> _cart = [];
  double _descuentoPorcentaje = 0;
  String _metodoPago = 'EFECTIVO';
  String? _cliente;
  bool _isLoading = false;
  String? _error;

  List<CartItem> get cart => _cart;
  double get descuentoPorcentaje => _descuentoPorcentaje;
  String get metodoPago => _metodoPago;
  bool get isLoading => _isLoading;
  String? get error => _error;

  VentaBloc({required this.repository});

  void agregarAlCarrito({
    required int productoId,
    required String nombre,
    required double precio,
    required double stock,
    int cantidad = 1,
  }) {
    final existingIndex = _cart.indexWhere((item) => item.productoId == productoId);

    if (existingIndex >= 0) {
      final nuevaCantidad = _cart[existingIndex].cantidad + cantidad;
      if (nuevaCantidad <= stock) {
        _cart[existingIndex].cantidad = nuevaCantidad;
      } else {
        _error = 'Stock insuficiente';
        notifyListeners();
        return;
      }
    } else {
      _cart.add(CartItem(
        productoId: productoId,
        nombre: nombre,
        precio: precio,
        cantidad: cantidad,
        stock: stock,
      ));
    }

    _error = null;
    notifyListeners();
  }

  void actualizarCantidad(int productoId, int cantidad) {
    final index = _cart.indexWhere((item) => item.productoId == productoId);
    if (index >= 0 && cantidad > 0 && cantidad <= _cart[index].stock) {
      _cart[index].cantidad = cantidad;
      notifyListeners();
    }
  }

  void eliminarDelCarrito(int productoId) {
    _cart.removeWhere((item) => item.productoId == productoId);
    notifyListeners();
  }

  void limpiarCarrito() {
    _cart.clear();
    _descuentoPorcentaje = 0;
    _cliente = null;
    notifyListeners();
  }

  void setDescuento(double porcentaje) {
    if (porcentaje >= 0 && porcentaje <= 100) {
      _descuentoPorcentaje = porcentaje;
      notifyListeners();
    }
  }

  void setMetodoPago(String metodo) {
    _metodoPago = metodo;
    notifyListeners();
  }

  double get subtotal => _cart.fold(0, (sum, item) => sum + item.subtotal);
  double get montoDescuento => subtotal * (_descuentoPorcentaje / 100);
  double get totalImpuesto => (subtotal - montoDescuento) * 0.10;
  double get total => subtotal - montoDescuento + totalImpuesto;
  int get totalItems => _cart.fold(0, (sum, item) => sum + item.cantidad);

  Future<bool> procesarVenta() async {
    if (_cart.isEmpty) {
      _error = 'El carrito está vacío';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final numeroVenta = 'VTA-${DateTime.now().millisecondsSinceEpoch}';

      final venta = {
        'numero_venta': numeroVenta,
        'fecha': DateTime.now().toIso8601String(),
        'total': total,
        'subtotal': subtotal,
        'impuesto': totalImpuesto,
        'descuento': montoDescuento,
        'metodo_pago': _metodoPago,
        'cliente': _cliente,
        'estado': 1,
      };

      final detalles = _cart.map((item) => {
        'producto_id': item.productoId,
        'nombre_producto': item.nombre,
        'cantidad': item.cantidad,
        'precio_unitario': item.precio,
        'subtotal': item.subtotal,
        'descuento': 0,
        'total': item.subtotal,
      }).toList();

      await repository.createVenta(venta, detalles);
      limpiarCarrito();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al procesar venta: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> obtenerHistorial() async {
    return await repository.getAllVentas();
  }

  Future<List<Map<String, dynamic>>> obtenerVentasPorRango(DateTime inicio, DateTime fin) async {
    return await repository.getVentasByDateRange(inicio, fin);
  }
}
