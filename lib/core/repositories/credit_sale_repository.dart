import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/credit_sale.dart';

class CreditSaleRepository {
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
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ventas_fiadas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        customer_name TEXT NOT NULL,
        customer_identity TEXT NOT NULL,
        customer_phone TEXT,
        total_amount REAL NOT NULL,
        paid_amount REAL NOT NULL,
        pending_amount REAL NOT NULL,
        sale_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }

  Future<int> createCreditSale(CreditSale creditSale) async {
    final db = await database;
    return await db.insert('ventas_fiadas', creditSale.toMap());
  }

  Future<List<CreditSale>> getAllCreditSales() async {
    final db = await database;
    final maps = await db.query('ventas_fiadas', orderBy: 'sale_date DESC');
    return maps.map((m) => CreditSale.fromMap(m)).toList();
  }

  Future<List<CreditSale>> getPendingCreditSales() async {
    final db = await database;
    final maps = await db.query(
      'ventas_fiadas',
      where: 'status != ?',
      whereArgs: ['paid'],
      orderBy: 'due_date ASC',
    );
    return maps.map((m) => CreditSale.fromMap(m)).toList();
  }

  Future<void> registerPayment(int id, double amount) async {
    final db = await database;
    final creditSale = await getCreditSaleById(id);
    if (creditSale == null) return;

    final newPaid = creditSale.paidAmount + amount;
    final newStatus = newPaid >= creditSale.totalAmount ? 'paid' : 'partial';

    await db.update(
      'ventas_fiadas',
      {
        'paid_amount': newPaid,
        'pending_amount': creditSale.totalAmount - newPaid,
        'status': newStatus,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<CreditSale?> getCreditSaleById(int id) async {
    final db = await database;
    final maps = await db.query('ventas_fiadas', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return CreditSale.fromMap(maps.first);
  }

  Future<double> getTotalPending() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(pending_amount) FROM ventas_fiadas WHERE status != "paid"');
    return ((result.first['SUM(pending_amount)'] ?? 0) as num).toDouble();
  }
}
