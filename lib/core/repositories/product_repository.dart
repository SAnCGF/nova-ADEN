import '../database/database_helper.dart';
import '../models/product.dart';

class ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> createProduct(Product product) async {
    final db = await _dbHelper.database;
    return await db.insert('productos', product.toMap());
  }

  Future<int> updateProduct(int id, Product product) async {
    final db = await _dbHelper.database;
    return await db.update(
      'productos',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Product>> getAllProducts() async {
    final db = await _dbHelper.database;
    final results = await db.query('productos', orderBy: 'nombre ASC');
    return results.map((m) => Product.fromMap(m)).toList();
  }

  Future<Product?> getProductById(int id) async {
    final db = await _dbHelper.database;
    final results = await db.query('productos', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return Product.fromMap(results.first);
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'productos',
      where: 'nombre LIKE ? OR codigo LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return results.map((m) => Product.fromMap(m)).toList();
  }

  // ✅ MÉTODO CRÍTICO: Actualizar stock después de venta
  Future<void> updateProductStock(int productId, int cantidad) async {
    final db = await _dbHelper.database;
    final product = await getProductById(productId);
    
    if (product == null) {
      throw Exception('Producto no encontrado: $productId');
    }
    
    final nuevoStock = product.stockActual - cantidad;
    
    if (nuevoStock < 0) {
      throw Exception('Stock insuficiente para producto ${product.nombre}');
    }
    
    await db.update(
      'productos',
      {
        'stock_actual': nuevoStock,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
  }
}
