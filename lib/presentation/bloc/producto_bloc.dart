import 'package:flutter/foundation.dart';
import 'package:nova_aden/core/repositories/product_repository.dart';
import 'package:nova_aden/core/models/product.dart';

class ProductoBloc extends ChangeNotifier {
  final ProductRepository repository;
  List<Product> _productos = [];
  List<Product> get productos => _productos;

  ProductoBloc({required this.repository});

  Future<void> cargarProductos() async {
    try {
      _productos = await repository.getAllProducts();
      notifyListeners();
    } catch (e) {
      _productos = [];
      notifyListeners();
    }
  }

  Future<bool> crearProducto(Map<String, dynamic> data) async {
    try {
      final product = Product(
        id: null,
        codigo: data['codigo'] ?? '',
        nombre: data['nombre'] ?? '',
        descripcion: data['descripcion'] ?? '',
        costoPromedio: (data['costoPromedio'] ?? 0).toDouble(),
        precioVenta: (data['precioVenta'] ?? 0).toDouble(),
        stockActual: (data['stockActual'] ?? 0).toInt(),
        stockMinimo: (data['stockMinimo'] ?? 0).toInt(),
        unidadMedida: data['unidadMedida'] ?? '',
      );
      await repository.createProduct(product);
      await cargarProductos();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> actualizarProducto(int id, Map<String, dynamic> data) async {
    try {
      final product = Product(
        id: id,
        codigo: data['codigo'] ?? '',
        nombre: data['nombre'] ?? '',
        descripcion: data['descripcion'] ?? '',
        costoPromedio: (data['costoPromedio'] ?? 0).toDouble(),
        precioVenta: (data['precioVenta'] ?? 0).toDouble(),
        stockActual: (data['stockActual'] ?? 0).toInt(),
        stockMinimo: (data['stockMinimo'] ?? 0).toInt(),
        unidadMedida: data['unidadMedida'] ?? '',
      );
      await repository.updateProduct(id, product);
      await cargarProductos();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> eliminarProducto(int id) async {
    try {
      await repository.deleteProduct(id);
      await cargarProductos();
      return true;
    } catch (e) {
      return false;
    }
  }
}
