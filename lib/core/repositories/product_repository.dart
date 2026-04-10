import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/product.dart';

class ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Future<Database> get _db async => await _dbHelper.database;

  Future<int> createProduct(Product p) async {
    final db = await _db;
    return await db.insert('productos', p.toMap());
  }

  Future<int> updateProduct(int id, Product p) async {
    final db = await _db;
    return await db.update('productos', p.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await _db;
    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Product>> getAllProducts() async {
    final db = await _db;
    final results = await db.query('productos', orderBy: 'nombre ASC');
    return results.map((m) => Product.fromMap(m)).toList();
  }

  Future<Product?> getProductById(int id) async {
    final db = await _db;
    final results = await db.query('productos', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return Product.fromMap(results.first);
  }

  Future<List<Product>> searchProducts(String q) async {
    final db = await _db;
    final results = await db.query('productos',
      where: 'nombre LIKE ? OR codigo LIKE ?',
      whereArgs: ['%$q%', '%$q%']);
    return results.map((m) => Product.fromMap(m)).toList();
  }

  Future<List<Product>> getLowStockProducts() async {
    final db = await _db;
    final results = await db.query('productos',
      where: 'stockActual <= stockMinimo');
    return results.map((m) => Product.fromMap(m)).toList();
  }

  // RF 10: Actualizar costo promedio ponderado
  Future<void> updateCostoPromedio(int productId, double nuevoCosto, int nuevaCantidad) async {
    final db = await _db;
    final product = await getProductById(productId);
    if (product != null) {
      final stockActual = product.stockActual;
      final costoActual = product.costo ?? 0.0;
      final totalStock = stockActual + nuevaCantidad;
      if (totalStock > 0) {
        final nuevoCostoPromedio = ((stockActual * costoActual) + (nuevaCantidad * nuevoCosto)) / totalStock;
        await db.update('productos', {'costo': nuevoCostoPromedio}, where: 'id = ?', whereArgs: [productId]);
      }
    }
  }

  // RF 40: Obtener cantidad de productos con stock bajo
  Future<int> getLowStockCount() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM productos WHERE stockActual <= stockMinimo',
    );
    return result.first['count'] as int? ?? 0;
  }

  // RF 40: Obtener total de productos
  Future<int> getTotalProducts() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM productos WHERE activo = 1');
    return result.first['count'] as int? ?? 0;
  }
}
