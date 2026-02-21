import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Future<DatabaseHelper> getInstance() async {
    await _instance._initDB();
    return _instance;
  }

  Future<Database> _initDB() async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nova_aden.db');

    _database = await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
    );

    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla Productos
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

    // Tabla Compras
    await db.execute('''
      CREATE TABLE IF NOT EXISTS compras(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero_compra TEXT NOT NULL UNIQUE,
        fecha TEXT NOT NULL,
        proveedor TEXT,
        total REAL NOT NULL,
        estado INTEGER DEFAULT 1
      )
    ''');

    // Tabla Detalle Compra
    await db.execute('''
      CREATE TABLE IF NOT EXISTS detalle_compras(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        compra_id INTEGER NOT NULL,
        producto_id INTEGER NOT NULL,
        cantidad REAL NOT NULL,
        precio_unitario REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY(compra_id) REFERENCES compras(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_productos_categoria ON productos(categoria)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_compras_fecha ON compras(fecha)');
  }

  Database get database {
    if (_database == null) {
      throw Exception('BD no inicializada. Llama getInstance() primero.');
    }
    return _database!;
  }

  Future<void> close() async {
    final db = await _database;
    db?.close();
    _database = null;
  }
}
