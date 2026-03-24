import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/supplier.dart';

class SupplierRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Future<Database> get _db async => await _dbHelper.database;

  Future<int> createSupplier(Supplier s) async {
    final db = await _db;
    return await db.insert('proveedores', s.toMap());
  }

  Future<int> updateSupplier(int id, Supplier s) async {
    final db = await _db;
    return await db.update('proveedores', s.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteSupplier(int id) async {
    final db = await _db;
    return await db.delete('proveedores', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Supplier>> getAllSuppliers() async {
    final db = await _db;
    final results = await db.query('proveedores', orderBy: 'nombre ASC');
    return results.map((m) => Supplier.fromMap(m)).toList();
  }

  Future<Supplier?> getSupplierById(int id) async {
    final db = await _db;
    final results = await db.query('proveedores', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return Supplier.fromMap(results.first);
  }
}
