import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../models/suspended_sale.dart';

class SuspendedSaleRepository {
  static Database? _database;
  final _uuid = const Uuid();

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
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ventas_pausadas (
        id TEXT PRIMARY KEY,
        items TEXT NOT NULL,
        total REAL NOT NULL,
        customer_name TEXT,
        customer_identity TEXT,
        suspended_at TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }

  Future<String> suspendSale(SuspendedSale sale) async {
    final db = await database;
    await db.insert('ventas_pausadas', sale.toMap());
    return sale.id;
  }

  Future<List<SuspendedSale>> getAllSuspendedSales() async {
    final db = await database;
    final maps = await db.query('ventas_pausadas', orderBy: 'suspended_at DESC');
    return maps.map((m) => SuspendedSale.fromMap(m)).toList();
  }

  Future<void> resumeSale(String id) async {
    final db = await database;
    await db.delete('ventas_pausadas', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getSuspendedCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM ventas_pausadas');
    return result.first['COUNT(*)'] as int;
  }
}
