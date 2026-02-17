import 'package:nova_aden/Dominio/entities/producto.dart';

abstract class ProductoRepository {
  Future<List<Producto>> obtenerTodos();
  Future<Producto?> obtenerPorId(int id);
  Future<int> guardar(Producto producto);
  Future<void> eliminar(int id);
}