import 'package:flutter/foundation.dart';
import '../../domain/repositories/producto_repository.dart';

class ProductoBloc extends ChangeNotifier {
  final ProductoRepository repository;
  List<Map<String, dynamic>> _productos = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get productos => _productos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProductoBloc({required this.repository});

  Future<void> cargarProductos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _productos = await repository.getAllProductos();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> crearProducto(Map<String, dynamic> producto) async {
    _isLoading = true;
    notifyListeners();

    try {
      producto['fecha_creacion'] = DateTime.now().toIso8601String();
      await repository.createProducto(producto);
      await cargarProductos();
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarProducto(int id, Map<String, dynamic> producto) async {
    try {
      final exito = await repository.updateProducto(id, producto);
      if (exito) await cargarProductos();
      return exito;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarProducto(int id) async {
    try {
      final exito = await repository.deleteProducto(id);
      if (exito) await cargarProductos();
      return exito;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarStock(int id, double cantidad, bool esEntrada) async {
    try {
      final exito = await repository.updateStock(id, cantidad, esEntrada);
      if (exito) await cargarProductos();
      return exito;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<Map<String, dynamic>> buscarProductos(String query) {
    if (query.isEmpty) return _productos;
    return _productos.where((p) {
      final nombre = p['nombre'].toString().toLowerCase();
      return nombre.contains(query.toLowerCase());
    }).toList();
  }
}
