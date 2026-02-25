import 'package:nova_aden/core/models/product.dart';
import 'package:nova_aden/core/database/database_helper.dart';

class ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// RF 1: Crear producto
  Future<bool> createProduct(Product product) async {
    try {
      final existing = await _dbHelper.getProductByCode(product.code);
      if (existing != null) return false;
      await _dbHelper.createProduct(product);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// RF 2: Editar producto
  Future<bool> updateProduct(Product product) async {
    try {
      if (product.id == null) return false;
      final updated = await _dbHelper.updateProduct(product);
      return updated > 0;
    } catch (e) {
      return false;
    }
  }

  /// RF 3: Eliminar producto
  Future<bool> deleteProduct(int id) async {
    try {
      final deleted = await _dbHelper.deleteProduct(id);
      return deleted > 0;
    } catch (e) {
      return false;
    }
  }

  /// RF 4: Buscar productos
  Future<List<Product>> searchProducts(String query) async {
    try {
      if (query.isEmpty) return await _dbHelper.getAllProducts();
      return await _dbHelper.searchProducts(query);
    } catch (e) {
      return [];
    }
  }

  /// RF 5: Productos con stock bajo
  Future<List<Product>> getLowStockProducts() async {
    try {
      return await _dbHelper.getLowStockProducts();
    } catch (e) {
      return [];
    }
  }

  /// Obtener todos los productos
  Future<List<Product>> getAllProducts() async {
    try {
      return await _dbHelper.getAllProducts();
    } catch (e) {
      return [];
    }
  }

  /// Obtener producto por ID
  Future<Product?> getProductById(int id) async {
    try {
      return await _dbHelper.getProductById(id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener producto por código (MÉTODO FALTANTE - AGREGADO)
  Future<Product?> getProductByCode(String code) async {
    try {
      return await _dbHelper.getProductByCode(code);
    } catch (e) {
      return null;
    }
  }

  /// Actualizar stock
  Future<bool> updateStock(int id, int newStock) async {
    try {
      final updated = await _dbHelper.updateStock(id, newStock);
      return updated > 0;
    } catch (e) {
      return false;
    }
  }

  /// Estadísticas rápidas
  Future<Map<String, int>> getStats() async {
    try {
      final total = await _dbHelper.getProductCount();
      final lowStock = await _dbHelper.getLowStockCount();
      return {'total': total, 'lowStock': lowStock};
    } catch (e) {
      return {'total': 0, 'lowStock': 0};
    }
  }
}

  Future<bool> updatePricesMassively({
    required String filterType,
    required String updateType,
    required double value,
    required bool increase,
  }) async {
    try {
      final db = await database;
      final productos = await getAllProductos();
      
      for (var producto in productos) {
        double nuevoPrecio = producto['precio_venta'] as double;
        
        if (updateType == 'percentage') {
          nuevoPrecio = increase 
            ? nuevoPrecio * (1 + value / 100)
            : nuevoPrecio * (1 - value / 100);
        } else {
          nuevoPrecio = increase
            ? nuevoPrecio + value
            : nuevoPrecio - value;
        }
        
        if (nuevoPrecio < 0) nuevoPrecio = 0;
        
        await db.update(
          'productos',
          {'precio_venta': nuevoPrecio},
          where: 'id = ?',
          whereArgs: [producto['id']],
        );
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
