import '../../domain/repositories/producto_repository.dart';
import '../datasources/database_helper.dart';

class ProductoRepositoryImpl implements ProductoRepository {
  final DatabaseHelper database;

  ProductoRepositoryImpl({required this.database});

  @override
  Future<List<Map<String, dynamic>>> getAllProductos() async {
    final db = database.database;
    return await db.query('productos', where: 'activo = ?', whereArgs: [1]);
  }

  @override
  Future<Map<String, dynamic>?> getProductoById(int id) async {
    final db = database.database;
    final maps = await db.query('productos', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? maps.first : null;
  }

  @override
  Future<int> createProducto(Map<String, dynamic> producto) async {
    final db = database.database;
    return await db.insert('productos', producto);
  }

  @override
  Future<bool> updateProducto(int id, Map<String, dynamic> producto) async {
    final db = database.database;
    final result = await db.update('productos', producto, where: 'id = ?', whereArgs: [id]);
    return result > 0;
  }

  @override
  Future<bool> deleteProducto(int id) async {
    final db = database.database;
    final result = await db.update('productos', {'activo': 0}, where: 'id = ?', whereArgs: [id]);
    return result > 0;
  }

  @override
  Future<bool> updateStock(int id, double cantidad, bool esEntrada) async {
    final db = database.database;
    final producto = await getProductoById(id);
    if (producto == null) return false;

    final stockActual = producto['stock'] as double;
    final nuevoStock = esEntrada ? stockActual + cantidad : stockActual - cantidad;

    if (nuevoStock < 0) return false;

    final result = await db.update(
      'productos',
      {'stock': nuevoStock},
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }
}
