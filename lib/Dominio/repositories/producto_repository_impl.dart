import 'package:nova_aden/Datos/datasources/app_database.dart';
import 'package:nova_aden/Dominio/entities/producto.dart';
import 'package:nova_aden/Dominio/repositories/producto_repository.dart';

class ProductoRepositoryImpl implements ProductoRepository {
  final AppDatabase _db;

  ProductoRepositoryImpl(this._db);

  @override
  Future<int> guardar(Producto producto) async {
    return await _db.into(_db.productos).insertOnConflictUpdate(
      ProductosCompanion(
        id: producto.id == 0 ? null : Value(producto.id),
        codigo: Value(producto.codigo),
        nombre: Value(producto.nombre),
        precioCompra: Value(producto.precioCompra),
        precioVenta: Value(producto.precioVenta),
        stock: Value(producto.stock),
      ),
    );
  }

  @override
  Future<List<Producto>> obtenerTodos() async {
    final rows = await _db.select(_db.productos).get();
    return rows.map((row) => Producto(
          id: row.id,
          codigo: row.codigo,
          nombre: row.nombre,
          precioCompra: row.precioCompra,
          precioVenta: row.precioVenta,
          stock: row.stock,
        )).toList();
  }

  @override
  Future<Producto?> obtenerPorId(int id) async {
    final rows = await (_db.select(_db.productos)..where((t) => t.id.equals(id))).get();
    return rows.isEmpty ? null : Producto(
          id: rows.first.id,
          codigo: rows.first.codigo,
          nombre: rows.first.nombre,
          precioCompra: rows.first.precioCompra,
          precioVenta: rows.first.precioVenta,
          stock: rows.first.stock,
        );
  }

  @override
  Future<void> eliminar(int id) async {
    await (_db.delete(_db.productos)..where((t) => t.id.equals(id))).go();
  }
}