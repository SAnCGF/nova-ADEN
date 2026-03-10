import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:nova_aden/core/models/product.dart';
import 'package:nova_aden/core/models/sale.dart';
import 'package:nova_aden/core/models/sale_item.dart';
import 'package:nova_aden/core/models/purchase.dart';
import 'package:nova_aden/core/models/purchase_item.dart';
import 'package:nova_aden/core/models/supplier.dart';
import 'package:nova_aden/core/models/inventory_adjustment.dart';
import 'package:nova_aden/core/models/inventory_loss.dart';
import 'package:nova_aden/core/models/loss_reason.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nova_aden.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
        await db.execute('PRAGMA journal_mode = WAL');
        await db.execute('PRAGMA synchronous = NORMAL');
        await db.execute('PRAGMA cache_size = 2000');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla de productos
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        cost REAL NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        min_stock INTEGER NOT NULL DEFAULT 5,
        unit TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabla de ventas
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_number TEXT NOT NULL UNIQUE,
        date TEXT NOT NULL,
        subtotal REAL NOT NULL,
        discount REAL DEFAULT 0,
        total REAL NOT NULL,
        paid REAL NOT NULL,
        change REAL NOT NULL,
        is_partial_payment INTEGER DEFAULT 0,
        customer_name TEXT,
        customer_phone TEXT,
        status TEXT DEFAULT 'completed',
        created_at TEXT NOT NULL
      )
    ''');

    // Tabla de ítems de venta
    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_code TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // Tabla de proveedores
    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        rfc TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabla de compras
    await db.execute('''
      CREATE TABLE purchases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_number TEXT NOT NULL UNIQUE,
        date TEXT NOT NULL,
        supplier_id INTEGER,
        supplier_name TEXT,
        subtotal REAL NOT NULL,
        total REAL NOT NULL,
        status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
      )
    ''');

    // Tabla de ítems de compra
    await db.execute('''
      CREATE TABLE purchase_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_cost REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (purchase_id) REFERENCES purchases(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // Tabla de ajustes de inventario
    await db.execute('''
      CREATE TABLE inventory_adjustments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        adjustment_number TEXT NOT NULL UNIQUE,
        date TEXT NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_code TEXT NOT NULL,
        quantity_before INTEGER NOT NULL,
        quantity_after INTEGER NOT NULL,
        adjustment_quantity INTEGER NOT NULL,
        type TEXT NOT NULL,
        reason TEXT NOT NULL,
        notes TEXT,
        unit_cost REAL NOT NULL,
        total_value REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // Tabla de motivos de merma
    await db.execute('''
      CREATE TABLE loss_reasons (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // Tabla de mermas
    await db.execute('''
      CREATE TABLE inventory_losses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        loss_number TEXT NOT NULL UNIQUE,
        date TEXT NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_code TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_cost REAL NOT NULL,
        total_value REAL NOT NULL,
        reason_id TEXT NOT NULL,
        reason_name TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (reason_id) REFERENCES loss_reasons(id)
      )
    ''');

    // Índices
    await db.execute('CREATE INDEX idx_products_name ON products(name)');
    await db.execute('CREATE INDEX idx_products_code ON products(code)');
    await db.execute('CREATE INDEX idx_products_stock ON products(stock)');
    await db.execute('CREATE INDEX idx_sales_date ON sales(date)');
    await db.execute('CREATE INDEX idx_sales_status ON sales(status)');
    await db.execute('CREATE INDEX idx_sale_items_sale_id ON sale_items(sale_id)');
    await db.execute('CREATE INDEX idx_purchases_date ON purchases(date)');
    await db.execute('CREATE INDEX idx_purchases_supplier ON purchases(supplier_id)');
    await db.execute('CREATE INDEX idx_adjustments_date ON inventory_adjustments(date)');
    await db.execute('CREATE INDEX idx_adjustments_product ON inventory_adjustments(product_id)');
    await db.execute('CREATE INDEX idx_losses_date ON inventory_losses(date)');
    await db.execute('CREATE INDEX idx_losses_reason ON inventory_losses(reason_id)');

    // Inicializar motivos de merma
    await _initializeLossReasons(db);
  }

  Future<void> _initializeLossReasons(Database db) async {
    final reasons = LossReason.defaults;
    final batch = db.batch();
    for (final reason in reasons) {
      batch.insert('loss_reasons', reason.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit();
  }

  // === PRODUCTOS ===
  Future<int> createProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<int> updateProduct(Product product) async {
    if (product.id == null) return 0;
    final db = await database;
    return await db.update('products', product.copyWith().toMap(), where: 'id = ?', whereArgs: [product.id]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final results = await db.query('products', where: 'name LIKE ? OR code LIKE ?', whereArgs: ['%$query%', '%$query%'], orderBy: 'name ASC', limit: 100);
    return results.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> getLowStockProducts() async {
    final db = await database;
    final results = await db.query('products', where: 'stock < min_stock', orderBy: 'stock ASC', limit: 50);
    return results.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> getAllProducts({int limit = 50, int offset = 0}) async {
    final db = await database;
    final results = await db.query('products', orderBy: 'name ASC', limit: limit, offset: offset);
    return results.map((map) => Product.fromMap(map)).toList();
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final results = await db.query('products', where: 'id = ?', whereArgs: [id], limit: 1);
    if (results.isEmpty) return null;
    return Product.fromMap(results.first);
  }

  Future<Product?> getProductByCode(String code) async {
    final db = await database;
    final results = await db.query('products', where: 'code = ?', whereArgs: [code], limit: 1);
    if (results.isEmpty) return null;
    return Product.fromMap(results.first);
  }

  Future<int> updateStock(int id, int newStock) async {
    final db = await database;
    return await db.update('products', {'stock': newStock, 'updated_at': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getProductCount() async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products')) ?? 0;
  }

  Future<int> getLowStockCount() async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products WHERE stock < min_stock')) ?? 0;
  }

  // === VENTAS ===
  Future<int> createSale(Sale sale) async {
    final db = await database;
    return await db.insert('sales', sale.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<int> createSaleItem(SaleItem item) async {
    final db = await database;
    return await db.insert('sale_items', item.toMap());
  }

  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final results = await db.query('sales', where: 'date BETWEEN ? AND ?', whereArgs: [start.toIso8601String(), end.toIso8601String()], orderBy: 'date DESC');
    return results.map((map) => Sale.fromMap(map)).toList();
  }

  Future<List<Sale>> getTodaySales() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return await getSalesByDateRange(start, end);
  }

  Future<Sale?> getSaleById(int id) async {
    final db = await database;
    final results = await db.query('sales', where: 'id = ?', whereArgs: [id], limit: 1);
    if (results.isEmpty) return null;
    return Sale.fromMap(results.first);
  }

  Future<List<SaleItem>> getSaleItems(int saleId) async {
    final db = await database;
    final results = await db.query('sale_items', where: 'sale_id = ?', whereArgs: [saleId]);
    return results.map((map) => SaleItem.fromMap(map)).toList();
  }

  Future<int> getSaleCount() async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM sales')) ?? 0;
  }

  Future<double> getTodaySalesTotal() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(total) as total FROM sales WHERE date >= ? AND status = ?', [start.toIso8601String(), 'completed']);
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<bool> createSaleWithItems(Sale sale, List<SaleItem> items) async {
    final db = await database;
    final batch = db.batch();
    batch.insert('sales', sale.toMap());
    for (final item in items) {
      batch.insert('sale_items', item.toMap());
    }
    final results = await batch.commit();
    return results.first is int && (results.first as int) > 0;
  }

  // === PROVEEDORES ===
  Future<int> createSupplier(Supplier supplier) async {
    final db = await database;
    return await db.insert('suppliers', supplier.toMap());
  }

  Future<List<Supplier>> getAllSuppliers() async {
    final db = await database;
    final results = await db.query('suppliers', orderBy: 'name ASC');
    return results.map((map) => Supplier.fromMap(map)).toList();
  }

  // === COMPRAS ===
  Future<int> createPurchase(Purchase purchase) async {
    final db = await database;
    return await db.insert('purchases', purchase.toMap());
  }

  Future<int> createPurchaseItem(PurchaseItem item) async {
    final db = await database;
    return await db.insert('purchase_items', item.toMap());
  }

  Future<List<Purchase>> getPurchasesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final results = await db.query('purchases', where: 'date BETWEEN ? AND ?', whereArgs: [start.toIso8601String(), end.toIso8601String()], orderBy: 'date DESC');
    return results.map((map) => Purchase.fromMap(map)).toList();
  }

  Future<List<PurchaseItem>> getPurchaseItems(int purchaseId) async {
    final db = await database;
    final results = await db.query('purchase_items', where: 'purchase_id = ?', whereArgs: [purchaseId]);
    return results.map((map) => PurchaseItem.fromMap(map)).toList();
  }

  Future<bool> createPurchaseWithItems(Purchase purchase, List<PurchaseItem> items, {bool updateStock = true}) async {
    final db = await database;
    final batch = db.batch();
    batch.insert('purchases', purchase.toMap());
    for (final item in items) {
      batch.insert('purchase_items', item.toMap());
    }
    final results = await batch.commit();
    return results.first is int && (results.first as int) > 0;
  }

  // === AJUSTES DE INVENTARIO ===
  Future<int> createAdjustment(InventoryAdjustment adjustment) async {
    final db = await database;
    return await db.insert('inventory_adjustments', adjustment.toMap());
  }

  Future<List<InventoryAdjustment>> getAdjustmentsByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final results = await db.query('inventory_adjustments', where: 'date BETWEEN ? AND ?', whereArgs: [start.toIso8601String(), end.toIso8601String()], orderBy: 'date DESC');
    return results.map((map) => InventoryAdjustment.fromMap(map)).toList();
  }

  Future<List<InventoryAdjustment>> getAdjustmentsByProduct(int productId) async {
    final db = await database;
    final results = await db.query('inventory_adjustments', where: 'product_id = ?', whereArgs: [productId], orderBy: 'date DESC');
    return results.map((map) => InventoryAdjustment.fromMap(map)).toList();
  }

  // === STOCK VALORADO ===
  Future<Map<String, dynamic>> getValuedStock() async {
    final db = await database;
    final results = await db.rawQuery('SELECT COUNT(*) as product_count, SUM(stock) as total_units, SUM(stock * cost) as total_value, AVG(cost) as avg_cost FROM products');
    if (results.isEmpty) return {'productCount': 0, 'totalUnits': 0, 'totalValue': 0.0, 'avgCost': 0.0};
    return {
      'productCount': results.first['product_count'] ?? 0,
      'totalUnits': results.first['total_units'] ?? 0,
      'totalValue': results.first['total_value'] ?? 0.0,
      'avgCost': results.first['avg_cost'] ?? 0.0,
    };
  }

  Future<List<Map<String, dynamic>>> getValuedStockByProduct() async {
    final db = await database;
    return await db.rawQuery('SELECT id, name, code, stock, cost, (stock * cost) as value FROM products ORDER BY value DESC');
  }

  // === MERMAS ===
  Future<int> createLoss(InventoryLoss loss) async {
    final db = await database;
    return await db.insert('inventory_losses', loss.toMap());
  }

  Future<List<InventoryLoss>> getLossesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final results = await db.query('inventory_losses', where: 'date BETWEEN ? AND ?', whereArgs: [start.toIso8601String(), end.toIso8601String()], orderBy: 'date DESC');
    return results.map((map) => InventoryLoss.fromMap(map)).toList();
  }

  Future<List<InventoryLoss>> getLossesByReason(String reasonId) async {
    final db = await database;
    final results = await db.query('inventory_losses', where: 'reason_id = ?', whereArgs: [reasonId], orderBy: 'date DESC');
    return results.map((map) => InventoryLoss.fromMap(map)).toList();
  }

  Future<List<LossReason>> getAllLossReasons() async {
    final db = await database;
    final results = await db.query('loss_reasons', where: 'is_active = 1');
    return results.map((map) => LossReason.fromMap(map)).toList();
  }

  Future<void> initializeLossReasons() async {
    final db = await database;
    await _initializeLossReasons(db);
  }

  Future<double> getTotalLossesValue(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(total_value) as total FROM inventory_losses WHERE date BETWEEN ? AND ?', [start.toIso8601String(), end.toIso8601String()]);
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // === CIERRE ===
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
