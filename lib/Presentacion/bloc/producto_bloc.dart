import 'package:flutter/material.dart';
import 'package:nova_aden/Dominio/entities/producto.dart';
import 'package:nova_aden/Dominio/repositories/producto_repository.dart';

class ProductoBloc extends ChangeNotifier {
  final ProductoRepository _repo;
  List<Producto> _productos = [];
  bool _cargando = false;

  ProductoBloc(this._repo);

  List<Producto> get productos => _productos;
  bool get cargando => _cargando;

  Future<void> cargarProductos() async {
    _cargando = true;
    notifyListeners();
    _productos = await _repo.obtenerTodos();
    _cargando = false;
    notifyListeners();
  }

  Future<void> guardarProducto(Producto producto) async {
    await _repo.guardar(producto);
    await cargarProductos();
  }
}