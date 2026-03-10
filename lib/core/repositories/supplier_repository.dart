import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '.../models/supplier.dart';

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
    return await openDatabase(path, version: 1);
  }

  // RF 7: Registrar nuevo proveedor
  Future<int> createSupplier(Supplier supplier) async {
    final db = await database;
    return await db.insert('proveedores', supplier.toMap());
  }

  // Actualizar proveedor existente
  Future<int> updateSupplier(int id, Supplier supplier) async {
    final db = await database;
    return await db.update(
      'proveedores',
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar proveedor
  Future<int> deleteSupplier(int id) async {
    final db = await database;
    return await db.delete('proveedores', where: 'id = ?', whereArgs: [id]);
  }

  // Obtener todos los proveedores
  Future<List<Supplier>> getAllSuppliers() async {
    final db = await database;
    final maps = await db.query('proveedores', orderBy: 'name ASC');
    return maps.map((map) => Supplier.fromMap(map)).toList();
  }

  // Obtener por ID
  Future<Supplier?> getSupplierById(int id) async {
    final db = await database;
    final maps = await db.query('proveedores', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Supplier.fromMap(maps.first);
  }

  // Histórico de compras por proveedor
  Future<List<Map<String, dynamic>>> getSupplierPurchaseHistory(int supplierId) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT c.*, COUNT(vd.id) as total_items
      FROM compras c
      LEFT JOIN compras_detalle vd ON c.id = vd.compra_id
      WHERE c.proveedor_id = ?
      GROUP BY c.id
      ORDER BY c.fecha DESC
    ''', [supplierId]);
    return results;
  }
}
