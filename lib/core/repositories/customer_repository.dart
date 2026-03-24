import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/customer.dart';

class CustomerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Future<Database> get _db async => await _dbHelper.database;

  Future<int> createCustomer(Customer c) async {
    final db = await _db;
    return await db.insert('clientes', c.toMap());
  }

  Future<int> updateCustomer(int id, Customer c) async {
    final db = await _db;
    return await db.update('clientes', c.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCustomer(int id) async {
    final db = await _db;
    return await db.delete('clientes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await _db;
    final results = await db.query('clientes', orderBy: 'nombre ASC');
    return results.map((m) => Customer.fromMap(m)).toList();
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await _db;
    final results = await db.query('clientes', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return Customer.fromMap(results.first);
  }

  Future<List<Customer>> searchCustomers(String q) async {
    final db = await _db;
    final results = await db.query('clientes',
      where: 'nombre LIKE ? OR carnetIdentidad LIKE ? OR telefono LIKE ?',
      whereArgs: ['%$q%', '%$q%', '%$q%']);
    return results.map((m) => Customer.fromMap(m)).toList();
  }
}
