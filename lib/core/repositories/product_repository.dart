import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

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
    return await openDatabase(path, version: 3, onCreate: _onCreate);
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

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('productos', where: 'activo = ?', whereArgs: [1]);
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final maps = await db.query('productos', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? Product.fromMap(maps.first) : null;
  }

  Future<Product?> getProductByCode(String code) async {
    final db = await database;
    final maps = await db.query('productos', where: 'codigo_barras = ? AND activo = ?', whereArgs: [code, 1]);
    return maps.isNotEmpty ? Product.fromMap(maps.first) : null;
  }

  Future<List<Product>> getLowStockProducts() async {
    final db = await database;
    final maps = await db.query('productos', where: 'stock <= stock_minimo AND activo = ?', whereArgs: [1]);
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final maps = await db.query('productos', where: '(nombre LIKE ? OR codigo_barras LIKE ?) AND activo = ?', whereArgs: ['%$query%', '%$query%', 1]);
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<int> createProduct(Product product) async {
    final db = await database;
    return await db.insert('productos', product.toMap());
  }

  Future<bool> updateProduct(int id, Product product) async {
    final db = await database;
    final result = await db.update('productos', product.toMap(), where: 'id = ?', whereArgs: [id]);
    return result > 0;
  }

  Future<bool> deleteProduct(int id) async {
    final db = await database;
    final result = await db.update('productos', {'activo': 0}, where: 'id = ?', whereArgs: [id]);
    return result > 0;
  }

  Future<bool> updateStock(int productId, int newStock, bool allowNegative) async {
    final db = await database;
    if (!allowNegative && newStock < 0) return false;
    final result = await db.update('productos', {'stock': newStock}, where: 'id = ?', whereArgs: [productId]);
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
      final products = await getAllProducts();
      for (var product in products) {
        double newPrice = product.precioVenta;
        if (updateType == 'percentage') {
          newPrice = increase ? newPrice * (1 + value / 100) : newPrice * (1 - value / 100);
        } else {
          newPrice = increase ? newPrice + value : newPrice - value;
        }
        if (newPrice < 0) newPrice = 0;
        await db.update('productos', {'precio_venta': newPrice}, where: 'id = ?', whereArgs: [product.id]);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // RF 50: Calcular costo promedio ponderado
  Future<double> calculateWeightedAverageCost(int productId) async {
    final db = await database;
    final purchases = await db.rawQuery(
      "SELECT cantidad, costo_unitario FROM compras_detalle WHERE producto_id = ? ORDER BY fecha ASC",
      [productId],
    );
    if (purchases.isEmpty) return 0.0;
    double totalCost = 0.0;
    int totalQuantity = 0;
    for (var purchase in purchases) {
      final quantity = purchase["cantidad"] as int;
      final cost = (purchase["costo_unitario"] as num).toDouble();
      totalCost += cost * quantity;
      totalQuantity += quantity;
    }
    return totalQuantity > 0 ? totalCost / totalQuantity : 0.0;
  }

  // RF 51: Sugerir precio por margen
  double suggestPriceByMargin(double cost, double marginPercent) {
    if (marginPercent <= 0 || marginPercent >= 100) {
      throw ArgumentError("El margen debe estar entre 0 y 100");
    }
    return cost / (1 - (marginPercent / 100));
  }

  double calculateMargin(double cost, double price) {
    if (price == 0) return 0.0;
    return ((price - cost) / price) * 100;
  }

  // RF 59: Ajustar stock tras conteo físico
  Future<int> adjustStock(int productId, int newStock, String reason, {String? notes}) async {
    final db = await database;
    final product = await getProductById(productId);
    if (product == null) throw Exception("Producto no encontrado");
    final previousStock = product.stockActual;
    final difference = newStock - previousStock;
    await db.update("productos", {"stockActual": newStock}, where: "id = ?", whereArgs: [productId]);
    await db.insert("ajustes_stock", {
      "product_id": productId,
      "product_name": product.nombre,
      "previous_stock": previousStock,
      "new_stock": newStock,
      "difference": difference,
      "reason": reason,
      "notes": notes,
      "adjusted_at": DateTime.now().toIso8601String(),
    });
    return difference;
  }


}
