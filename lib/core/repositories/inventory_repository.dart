import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'product_repository.dart';
import '../models/product.dart';

class InventoryRepository {
  final ProductRepository _productRepo = ProductRepository();
  static Database? _database;

  static const List<Map<String, String>> _reasons = [
    {'id': '1', 'name': 'Dañado'},
    {'id': '2', 'name': 'Vencido'},
    {'id': '3', 'name': 'Pérdida'},
    {'id': '4', 'name': 'Robo'},
    {'id': '5', 'name': 'Ajuste'},
    {'id': '6', 'name': 'Devolución'},
  ];

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nova_aden.db');
    return await openDatabase(path, version: 3, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS inventory_losses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        quantity INTEGER,
        reason_id TEXT,
        reason_name TEXT,
        date TEXT,
        notes TEXT
      )
    ''');
  }

  Future<void> initializeReasons() async {}

  List<Map<String, String>> getLossReasons() => _reasons;

  Future<bool> registerLoss({
    required int productId,
    required int quantity,
    required String reasonId,
    required String reasonName,
    String? notes,
  }) async {
    try {
      final db = await database;
      final product = await _productRepo.getProductById(productId);
      if (product == null) return false;
      final newStock = product.stockActual - quantity;
      if (newStock < 0) return false;
      await db.insert('inventory_losses', {
        'product_id': productId,
        'quantity': quantity,
        'reason_id': reasonId,
        'reason_name': reasonName,
        'date': DateTime.now().toIso8601String(),
        'notes': notes,
      });
      await _productRepo.updateStock(productId, newStock, false);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getLosses() async {
    try {
      final db = await database;
      return await db.query('inventory_losses', orderBy: 'date DESC');
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getValuedStock() async {
    try {
      final products = await _productRepo.getAllProducts();
      double total = 0;
      for (var p in products) {
        total += p.stockActual * p.costoPromedio;
      }
      return {
        'totalValue': total,
        'totalProducts': products.length,
        'lowStockCount': products.where((p) => p.stockActual <= p.stockMinimo).length,
      };
    } catch (e) {
      return {'totalValue': 0.0, 'totalProducts': 0, 'lowStockCount': 0};
    }
  }

  Future<List<Map<String, dynamic>>> getValuedStockByProduct() async {
    try {
      final products = await _productRepo.getAllProducts();
      return products.map((p) => {
        'id': p.id,
        'name': p.nombre,
        'stock': p.stockActual,
        'cost': p.costoPromedio,
        'totalValue': p.stockActual * p.costoPromedio,
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
