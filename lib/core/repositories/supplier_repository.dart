import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/supplier.dart';

class SupplierRepository {
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
      CREATE TABLE IF NOT EXISTS proveedores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        telefono TEXT,
        email TEXT,
        direccion TEXT,
        rfc TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<List<Supplier>> getAllSuppliers() async {
    final db = await database;
    final maps = await db.query('proveedores', orderBy: 'nombre ASC');
    return maps.map((m) => Supplier.fromMap(m)).toList();
  }

  Future<int> createSupplier(Supplier supplier) async {
    final db = await database;
    return await db.insert('proveedores', supplier.toMap());
  }

  // RF 49: Ver histórico por proveedor
  Future<List<Map<String, dynamic>>> getSupplierHistory(int supplierId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        c.*,
        p.nombre as producto_nombre,
        p.codigo as producto_codigo
      FROM compras c
      INNER JOIN productos p ON c.producto_id = p.id
      WHERE c.proveedor_id = ?
      ORDER BY c.fecha DESC
    ''', [supplierId]);
  }

  Future<List<Supplier>> searchSuppliers(String query) async {
    final db = await database;
    final maps = await db.query(
      'proveedores',
      where: 'nombre LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((m) => Supplier.fromMap(m)).toList();
  }
}
