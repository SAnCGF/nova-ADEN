import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ProductRepository {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nova_aden.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS productos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        precio_compra REAL NOT NULL,
        precio_venta REAL NOT NULL,
        stock REAL DEFAULT 0,
        stock_minimo REAL DEFAULT 5,
        categoria TEXT,
        codigo_barras TEXT,
        unidad_medida TEXT DEFAULT 'UNIDAD',
        activo INTEGER DEFAULT 1,
        fecha_creacion TEXT
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getAllProductos() async {
    final db = await database;
    return await db.query('productos', where: 'activo = ?', whereArgs: [1]);
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    return getAllProductos();
  }

  Future<Map<String, dynamic>?> getProductoById(int id) async {
    final db = await database;
    final maps = await db.query('productos', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<Map<String, dynamic>?> getProductById(int id) async {
    return getProductoById(id);
  }

  Future<Map<String, dynamic>?> getProductByCode(String code) async {
    final db = await database;
    final maps = await db.query('productos', 
      where: 'codigo_barras = ? AND activo = ?', 
      whereArgs: [code, 1]);
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<List<Map<String, dynamic>>> getLowStockProducts() async {
    final db = await database;
    return await db.query('productos', 
      where: 'stock <= stock_minimo AND activo = ?');
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final db = await database;
    return await db.query('productos',
      where: '(nombre LIKE ? OR codigo_barras LIKE ?) AND activo = ?',
      whereArgs: ['%$query%', '%$query%', 1]);
  }

  Future<int> createProducto(Map<String, dynamic> producto) async {
    final db = await database;
    return await db.insert('productos', producto);
  }

  Future<int> createProduct(Map<String, dynamic> product) async {
    return createProducto(product);
  }

  Future<bool> updateProducto(int id, Map<String, dynamic> producto) async {
    final db = await database;
    final result = await db.update('productos', producto, where: 'id = ?', whereArgs: [id]);
    return result > 0;
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> product) async {
    return updateProducto(id, product);
  }

  Future<bool> deleteProducto(int id) async {
    final db = await database;
    final result = await db.update('productos', {'activo': 0}, where: 'id = ?', whereArgs: [id]);
    return result > 0;
  }

  Future<bool> deleteProduct(int id) async {
    return deleteProducto(id);
  }

  Future<bool> updateStock(int productId, double newStock, bool allowNegative) async {
    final db = await database;
    if (!allowNegative && newStock < 0) return false;
    
    final result = await db.update(
      'productos',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [productId],
    );
    return result > 0;
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
