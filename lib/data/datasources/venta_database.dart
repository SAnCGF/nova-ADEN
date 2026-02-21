import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class VentaDatabase {
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
      CREATE TABLE IF NOT EXISTS ventas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero_venta TEXT NOT NULL UNIQUE,
        fecha TEXT NOT NULL,
        total REAL NOT NULL,
        subtotal REAL NOT NULL,
        impuesto REAL DEFAULT 0,
        descuento REAL DEFAULT 0,
        metodo_pago TEXT DEFAULT 'EFECTIVO',
        cliente TEXT,
        vendedor TEXT,
        estado INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS detalle_ventas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        venta_id INTEGER NOT NULL,
        producto_id INTEGER NOT NULL,
        nombre_producto TEXT NOT NULL,
        cantidad INTEGER NOT NULL,
        precio_unitario REAL NOT NULL,
        subtotal REAL NOT NULL,
        descuento REAL DEFAULT 0,
        total REAL NOT NULL,
        FOREIGN KEY(venta_id) REFERENCES ventas(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_ventas_fecha ON ventas(fecha)');
  }

  Future<int> insertVenta(Map<String, dynamic> venta) async {
    final db = await database;
    return await db.insert('ventas', venta);
  }

  Future<List<Map<String, dynamic>>> getAllVentas() async {
    final db = await database;
    return await db.query('ventas', orderBy: 'fecha DESC');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
