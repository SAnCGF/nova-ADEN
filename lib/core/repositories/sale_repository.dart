import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'product_repository.dart';

class SaleRepository {
  final ProductRepository _productRepo = ProductRepository();
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
    await db.execute('''CREATE TABLE IF NOT EXISTS ventas(id INTEGER PRIMARY KEY AUTOINCREMENT, numero_venta TEXT, fecha TEXT, total REAL, subtotal REAL, impuesto REAL DEFAULT 0, descuento REAL DEFAULT 0, metodo_pago TEXT, cliente TEXT, vendedor TEXT, estado INTEGER DEFAULT 1)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS detalle_ventas(id INTEGER PRIMARY KEY AUTOINCREMENT, venta_id INTEGER, producto_id INTEGER, nombre_producto TEXT, cantidad INTEGER, precio_unitario REAL, subtotal REAL, descuento REAL DEFAULT 0, total REAL)''');
  }

  Future<int> registerSale(Map<String, dynamic> sale, List<Map<String, dynamic>> items, bool allowNegative) async {
    final db = await database;
    int id = 0;
    await db.transaction((txn) async {
      id = await txn.insert('ventas', sale);
      for (var item in items) {
        item['venta_id'] = id;
        await txn.insert('detalle_ventas', item);
        final p = await _productRepo.getProductById(item['producto_id']);
        if (p != null) {
          final newStock = p.stockActual - ((item['cantidad'] ?? 0) as num).toInt();
          await _productRepo.updateStock(item['producto_id'], newStock, allowNegative);
        }
      }
    });
    return id;
  }

  Future<List<Map<String, dynamic>>> getAllSales() async {
    try {
      final db = await database;
      return await db.query('ventas', orderBy: 'fecha DESC');
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTodaySales() async {
    try {
      final db = await database;
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      return await db.query('ventas', where: 'fecha >= ?', whereArgs: [start.toIso8601String()]);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSalesByDateRange(DateTime start, DateTime end) async {
    try {
      final db = await database;
      return await db.query('ventas', where: 'fecha BETWEEN ? AND ?', whereArgs: [start.toIso8601String(), end.toIso8601String()]);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSaleDetail(int saleId) async {
    try {
      final db = await database;
      return await db.query('detalle_ventas', where: 'venta_id = ?', whereArgs: [saleId]);
    } catch (e) {
      return [];
    }
  }
}
