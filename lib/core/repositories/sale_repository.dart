import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/sale.dart';

class SaleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Future<Database> get _db async => await _dbHelper.database;

  Future<int> createSale(int? clienteId, List<SaleLine> lines, double total, double paidAmount, double pendingAmount, String? notes) async {
    final db = await _db;
    return await db.transaction((txn) async {
      final ventaId = await txn.insert('ventas', {
        'cliente_id': clienteId, 'fecha': DateTime.now().toIso8601String(),
        'total': total, 'monto_pagado': paidAmount, 'monto_pendiente': pendingAmount,
        'notas_credito': notes, 'es_fiado': pendingAmount > 0 ? 1 : 0,
      });
      for (final line in lines) {
        await txn.insert('venta_detalles', {
          'venta_id': ventaId, 'producto_id': line.productoId,
          'cantidad': line.cantidad, 'precio_unitario': line.precioUnitario,
          'subtotal': (line.subtotal as num).toDouble(),
        });
        await txn.rawUpdate('UPDATE productos SET stock_actual = stock_actual - ? WHERE id = ?', [line.cantidad, line.productoId]);
      }
      return ventaId;
    });
  }

  Future<List<Sale>> getAllSales() async {
    final db = await _db;
    final results = await db.query('ventas', orderBy: 'fecha DESC');
    return results.map((m) => Sale.fromMap(m)).toList();
  }

  // RF 21: Filtro por rango de fechas
  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
    final db = await _db;
    final results = await db.query(
      'ventas',
      where: 'fecha >= ? AND fecha <= ?',
      whereArgs: [start.toIso8601String(), end.add(const Duration(days: 1)).toIso8601String()],
      orderBy: 'fecha DESC',
    );
    return results.map((m) => Sale.fromMap(m)).toList();
  }

  // RF 20: Ventas del día
  Future<List<Sale>> getTodaySales() async {
    final now = DateTime.now();
    return getSalesByDateRange(DateTime(now.year, now.month, now.day), DateTime(now.year, now.month, now.day));
  }

  // RF 22: Detalle de venta con líneas
  Future<Map<String, dynamic>> getSaleDetail(int saleId) async {
    final db = await _db;
    final sale = await db.query('ventas', where: 'id = ?', whereArgs: [saleId]);
    if (sale.isEmpty) return {};
    
    final lines = await db.rawQuery('''
      SELECT vd.*, p.nombre as producto_nombre 
      FROM venta_detalles vd 
      JOIN productos p ON vd.producto_id = p.id 
      WHERE vd.venta_id = ?
    ''', [saleId]);
    
    return {
      'venta': Sale.fromMap(sale.first),
      'lineas': lines,
    };
  }

  // RF 31: Reporte de ventas detallado
  Future<List<Map<String, dynamic>>> getDetailedSalesReport({DateTime? start, DateTime? end}) async {
    final db = await _db;
    String where = '1=1';
    List<dynamic> args = [];
    
    if (start != null) { where += ' AND fecha >= ?'; args.add(start.toIso8601String()); }
    if (end != null) { where += ' AND fecha <= ?'; args.add(end.add(const Duration(days: 1)).toIso8601String()); }
    
    return await db.rawQuery('''
      SELECT v.id, v.fecha, v.total, v.es_fiado, c.nombre as cliente,
             GROUP_CONCAT(p.nombre || ' x' || vd.cantidad) as productos
      FROM ventas v
      LEFT JOIN clientes c ON v.cliente_id = c.id
      JOIN venta_detalles vd ON v.id = vd.venta_id
      JOIN productos p ON vd.producto_id = p.id
      WHERE $where
      GROUP BY v.id ORDER BY v.fecha DESC
    ''', args);
  }

  // RF 32: Reporte de ganancias
  Future<Map<String, dynamic>> getProfitReport({DateTime? start, DateTime? end}) async {
    final db = await _db;
    String where = '1=1';
    List<dynamic> args = [];
    
    if (start != null) { where += ' AND fecha >= ?'; args.add(start.toIso8601String()); }
    if (end != null) { where += ' AND fecha <= ?'; args.add(end.add(const Duration(days: 1)).toIso8601String()); }
    
    final result = await db.rawQuery('''
      SELECT 
        SUM(v.total) as ingresos_totales,
        SUM(vd.cantidad * p.costo) as costo_total,
        SUM(v.total - (vd.cantidad * p.costo)) as ganancia_total,
        COUNT(DISTINCT v.id) as total_ventas
      FROM ventas v
      JOIN venta_detalles vd ON v.id = vd.venta_id
      JOIN productos p ON vd.producto_id = p.id
      WHERE $where
    ''', args);
    
    final r = result.first;
    return {
      'ingresos': (r['ingresos_totales'] as num?)?.toDouble() ?? 0.0,
      'costos': (r['costo_total'] as num?)?.toDouble() ?? 0.0,
      'ganancia': (r['ganancia_total'] as num?)?.toDouble() ?? 0.0,
      'margen': ((r['ganancia_total'] as num?)?.toDouble() ?? 0.0) / ((r['ingresos_totales'] as num?)?.toDouble() ?? 1.0) * 100,
      'ventas': r['total_ventas'] as int? ?? 0,
    };
  }

  Future<double> getTotalIngresos() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COALESCE(SUM(total), 0) as total FROM ventas');
    final value = result.first['total'];
    return value == null ? 0.0 : (value as num).toDouble();
  }
}
