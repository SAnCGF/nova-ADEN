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
}
