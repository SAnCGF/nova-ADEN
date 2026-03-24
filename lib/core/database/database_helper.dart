import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nova_aden.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Productos (RF 1-5)
    await db.execute('''
      CREATE TABLE productos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        codigo TEXT NOT NULL,
        costo REAL NOT NULL,
        precioVenta REAL NOT NULL,
        stockActual INTEGER NOT NULL,
        stockMinimo INTEGER NOT NULL,
        unidadMedida TEXT NOT NULL,
        categoria TEXT
      )
    ''');

    // Proveedores (RF 7)
    await db.execute('''
      CREATE TABLE proveedores(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        telefono TEXT,
        email TEXT,
        direccion TEXT
      )
    ''');

    // Clientes (NEW - Para ventas)
    await db.execute('''
      CREATE TABLE clientes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        carnetIdentidad TEXT NOT NULL,
        telefono TEXT NOT NULL,
        email TEXT,
        direccion TEXT
      )
    ''');

    // Compras (RF 6-11)
    await db.execute('''
      CREATE TABLE compras(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        proveedor_id INTEGER,
        fecha TEXT NOT NULL,
        total REAL NOT NULL,
        estado TEXT DEFAULT 'pendiente',
        FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE compras_detalle(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        compra_id INTEGER NOT NULL,
        producto_id INTEGER NOT NULL,
        cantidad INTEGER NOT NULL,
        costoUnitario REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (compra_id) REFERENCES compras(id),
        FOREIGN KEY (producto_id) REFERENCES productos(id)
      )
    ''');

    // Ventas (RF 12-16)
    await db.execute('''
      CREATE TABLE ventas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER,
        fecha TEXT NOT NULL,
        total REAL NOT NULL,
        estado TEXT DEFAULT 'pagado',
        FOREIGN KEY (cliente_id) REFERENCES clientes(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ventas_detalle(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        venta_id INTEGER NOT NULL,
        producto_id INTEGER NOT NULL,
        cantidad INTEGER NOT NULL,
        precioUnitario REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (venta_id) REFERENCES ventas(id),
        FOREIGN KEY (producto_id) REFERENCES productos(id)
      )
    ''');
  }
}
