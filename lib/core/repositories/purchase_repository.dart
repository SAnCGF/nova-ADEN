import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'product_repository.dart';

class PurchaseRepository {
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
    await db.execute('''CREATE TABLE IF NOT EXISTS compras(id INTEGER PRIMARY KEY AUTOINCREMENT, numero_compra TEXT, fecha TEXT, proveedor TEXT, total REAL, estado INTEGER DEFAULT 1)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS detalle_compras(id INTEGER PRIMARY KEY AUTOINCREMENT, compra_id INTEGER, producto_id INTEGER, cantidad REAL, precio_unitario REAL, subtotal REAL)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS proveedores(id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT, rnc TEXT, telefono TEXT, email TEXT, direccion TEXT, activo INTEGER DEFAULT 1)''');
  }

  Future<int> registerPurchase(Map<String, dynamic> purchase, List<Map<String, dynamic>> items) async {
    final db = await database;
    int id = 0;
    await db.transaction((txn) async {
      id = await txn.insert('compras', purchase);
      for (var item in items) {
        item['compra_id'] = id;
        await txn.insert('detalle_compras', item);
        final p = await _productRepo.getProductById(item['producto_id']);
        if (p != null) {
          final newStock = p.stockActual + ((item['cantidad'] ?? 0) as num).toInt();
          await _productRepo.updateStock(item['producto_id'], newStock, true);
        }
      }
    });
    return id;
  }

  Future<List<Map<String, dynamic>>> getAllPurchases() async {
    try {
      final db = await database;
      return await db.query('compras', orderBy: 'fecha DESC');
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTodayPurchases() async {
    try {
      final db = await database;
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      return await db.query('compras', where: 'fecha >= ?', whereArgs: [start.toIso8601String()]);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPurchasesByDateRange(DateTime start, DateTime end) async {
    try {
      final db = await database;
      return await db.query('compras', where: 'fecha BETWEEN ? AND ?', whereArgs: [start.toIso8601String(), end.toIso8601String()]);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllSuppliers() async {
    try {
      final db = await database;
      return await db.query('proveedores', where: 'activo = ?', whereArgs: [1]);
    } catch (e) {
      return [];
    }
  }
}
