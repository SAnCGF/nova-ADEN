import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../models/inventory_adjustment.dart';
import '../models/waste_record.dart';

class InventoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Future<Database> get _db async => await _dbHelper.database;

  // RF 23: Stock valorado
  Future<List<Map<String, dynamic>>> getValuedStock() async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT p.*, (p.costo * p.stock_actual) as valor_total 
      FROM productos p ORDER BY valor_total DESC
    ''');
    return results;
  }

  // RF 24-25: Registrar ajuste de inventario
  Future<int> registerAdjustment(InventoryAdjustment adj) async {
    final db = await _db;
    return await db.transaction((txn) async {
      await txn.insert('ajustes_inventario', adj.toMap());
      // Actualizar stock del producto
      final multiplier = adj.type == AdjustmentType.positive ? 1 : -1;
      await txn.rawUpdate(
        'UPDATE productos SET stock_actual = stock_actual + ? WHERE id = ?',
        [adj.cantidad * multiplier, adj.productoId],
      );
      return 1;
    });
  }

  // RF 26-27: Registrar merma
  Future<int> registerWaste(WasteRecord waste) async {
    final db = await _db;
    return await db.transaction((txn) async {
      await txn.insert('mermas', waste.toMap());
      // Reducir stock
      await txn.rawUpdate(
        'UPDATE productos SET stock_actual = stock_actual - ? WHERE id = ?',
        [waste.cantidad, waste.productoId],
      );
      return 1;
    });
  }

  // RF 26: Mermas masivas
  Future<int> registerBulkWaste(List<WasteRecord> wastes) async {
    final db = await _db;
    return await db.transaction((txn) async {
      int count = 0;
      for (final w in wastes) {
        await txn.insert('mermas', w.toMap());
        await txn.rawUpdate(
          'UPDATE productos SET stock_actual = stock_actual - ? WHERE id = ?',
          [w.cantidad, w.productoId],
        );
        count++;
      }
      return count;
    });
  }

  // RF 28: Listar mermas con filtros
  Future<List<WasteRecord>> getWastes({
    WasteReason? reason,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _db;
    String where = '1=1';
    List<dynamic> args = [];
    
    if (reason != null) {
      where += ' AND motivo = ?';
      args.add(reason.toString().split('.').last);
    }
    if (startDate != null) {
      where += ' AND fecha >= ?';
      args.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      where += ' AND fecha <= ?';
      args.add(endDate.add(const Duration(days: 1)).toIso8601String());
    }
    
    final results = await db.query('mermas', where: where, whereArgs: args, orderBy: 'fecha DESC');
    return results.map((m) => WasteRecord.fromMap(m)).toList();
  }

  // RF 29: Reporte de inventario
  Future<Map<String, dynamic>> getInventoryReport() async {
    final db = await _db;
    final products = await db.query('productos');
    final totalProducts = products.length;
    final totalStock = products.fold(0, (s, p) => s + (p['stock_actual'] as int));
    final totalValue = products.fold(0.0, (s, p) => s + ((p['costo'] as num) * (p['stock_actual'] as int)));
    final lowStock = products.where((p) => (p['stock_actual'] as int) <= (p['stock_minimo'] as int)).length;
    
    return {
      'totalProductos': totalProducts,
      'totalStock': totalStock,
      'valorTotal': totalValue,
      'alertasStock': lowStock,
      'productos': products,
    };
  }

  // RF 30: Movimientos por producto
  Future<List<Map<String, dynamic>>> getProductMovements(int productId) async {
    final db = await _db;
    final movements = <Map<String, dynamic>>[];
    
    // Compras
    final purchases = await db.rawQuery('''
      SELECT 'compra' as tipo, vd.cantidad, vd.precio_unitario as costo, v.fecha
      FROM venta_detalles vd JOIN ventas v ON vd.venta_id = v.id
      WHERE vd.producto_id = ?
    ''', [productId]);
    movements.addAll(purchases);
    
    // Ventas
    final sales = await db.rawQuery('''
      SELECT 'venta' as tipo, vd.cantidad, vd.precio_unitario as precio, v.fecha
      FROM venta_detalles vd JOIN ventas v ON vd.venta_id = v.id
      WHERE vd.producto_id = ?
    ''', [productId]);
    movements.addAll(sales);
    
    // Ajustes
    final adjustments = await db.query('ajustes_inventario', where: 'producto_id = ?', whereArgs: [productId]);
    movements.addAll(adjustments);
    
    // Mermas
    final wastes = await db.query('mermas', where: 'producto_id = ?', whereArgs: [productId]);
    movements.addAll(wastes);
    
    return movements..sort((a, b) => (b['fecha'] as String).compareTo(a['fecha'] as String));
  }

  // RF 33: Compras por proveedor
  Future<Map<String, dynamic>> getPurchasesBySupplier(int supplierId) async {
    final db = await _db;
    // Simplificado: retornar productos comprados de este proveedor
    final results = await db.rawQuery('''
      SELECT p.nombre, SUM(vd.cantidad) as total_comprado, AVG(vd.precio_unitario) as costo_promedio
      FROM productos p
      JOIN compra_detalles cd ON p.id = cd.producto_id
      JOIN compras c ON cd.compra_id = c.id
      WHERE c.proveedor_id = ?
      GROUP BY p.id
    ''', [supplierId]);
    
    return {
      'proveedor_id': supplierId,
      'productos': results,
      'totalInversion': results.fold(0.0, (s, r) => s + ((r['total_comprado'] as int) * (r['costo_promedio'] as num))),
    };
  }
}
