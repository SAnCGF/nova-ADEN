import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MigrationService {
  static const String _versionKey = 'db_version';
  static const int _currentVersion = 1;

  // RF 78: Migrar datos de versión anterior
  static Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 1) {
      // Migración inicial
      await _migrateToV1(db);
    }
  }

  static Future<void> _migrateToV1(Database db) async {
    // Tablas base
    await db.execute('''
      CREATE TABLE IF NOT EXISTS productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        costoPromedio REAL,
        precioVenta REAL,
        stockActual INTEGER,
        stockMinimo INTEGER,
        categoria TEXT,
        unidadMedida TEXT,
        isActive INTEGER DEFAULT 1,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero_venta TEXT,
        fecha TEXT,
        total REAL,
        estado TEXT,
        cliente TEXT,
        identidad TEXT,
        telefono TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ventas_detalle (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        venta_id INTEGER,
        producto_id INTEGER,
        cantidad INTEGER,
        precio_unitario REAL,
        subtotal REAL,
        descuento REAL,
        total REAL
      )
    ''');

    // Guardar versión actual
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_versionKey, _currentVersion);
  }

  static Future<int> getCurrentVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_versionKey) ?? 0;
  }

  static Future<bool> needsMigration() async {
    final current = await getCurrentVersion();
    return current < _currentVersion;
  }
}
