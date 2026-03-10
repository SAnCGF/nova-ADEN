import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ReportRepository {
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

  // RF 62: Reporte de rotación de productos
  Future<List<Map<String, dynamic>>> getProductRotationReport({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    
    return await db.rawQuery('''
      SELECT p.id, p.nombre, p.codigo,
        COALESCE(SUM(vd.cantidad), 0) as total_vendido,
        COALESCE(SUM(vd.cantidad * vd.precio_unitario), 0) as total_ingresos,
        p.stockActual as stock_actual
      FROM productos p
      LEFT JOIN ventas_detalle vd ON p.id = vd.producto_id
      LEFT JOIN ventas v ON vd.venta_id = v.id
      WHERE v.fecha BETWEEN ? AND ?
      GROUP BY p.id
      ORDER BY total_vendido DESC
    ''', [start.toIso8601String(), end.toIso8601String()]);
  }

  // RF 63: Reporte de margen por producto
  Future<List<Map<String, dynamic>>> getMarginReport({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    
    return await db.rawQuery('''
      SELECT p.id, p.nombre, p.codigo,
        p.costoPromedio as costo,
        p.precioVenta as precio,
        (p.precioVenta - p.costoPromedio) as margen_unitario,
        CASE WHEN p.precioVenta > 0 THEN ((p.precioVenta - p.costoPromedio) / p.precioVenta * 100) ELSE 0 END as margen_porcentaje,
        COALESCE(SUM(vd.cantidad), 0) as total_vendido,
        COALESCE(SUM(vd.cantidad * (vd.precio_unitario - p.costoPromedio)), 0) as margen_total
      FROM productos p
      LEFT JOIN ventas_detalle vd ON p.id = vd.producto_id
      LEFT JOIN ventas v ON vd.venta_id = v.id
      WHERE v.fecha BETWEEN ? AND ?
      GROUP BY p.id
      ORDER BY margen_total DESC
    ''', [start.toIso8601String(), end.toIso8601String()]);
  }

  // RF 64: Reporte de flujo de caja
  Future<Map<String, dynamic>> getCashFlowReport({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    
    final ingresos = await db.rawQuery('''
      SELECT COALESCE(SUM(total), 0) as total FROM ventas 
      WHERE fecha BETWEEN ? AND ? AND estado = 'completed'
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    final egresos = await db.rawQuery('''
      SELECT COALESCE(SUM(total), 0) as total FROM compras 
      WHERE fecha BETWEEN ? AND ?
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    final totalIngresos = ((ingresos.first['total'] ?? 0) as num).toDouble();
    final totalEgresos = ((egresos.first['total'] ?? 0) as num).toDouble();
    
    return {
      'periodo_inicio': start.toIso8601String(),
      'periodo_fin': end.toIso8601String(),
      'ingresos': totalIngresos,
      'egresos': totalEgresos,
      'balance': totalIngresos - totalEgresos,
    };
  }

  // RF 67: Datos para gráficos
  Future<List<Map<String, dynamic>>> getSalesChartData({int days = 7}) async {
    final db = await database;
    final start = DateTime.now().subtract(Duration(days: days));
    
    return await db.rawQuery('''
      SELECT DATE(fecha) as fecha, COUNT(*) as cantidad_ventas, SUM(total) as total_ventas
      FROM ventas
      WHERE fecha >= ?
      GROUP BY DATE(fecha)
      ORDER BY fecha ASC
    ''', [start.toIso8601String()]);
  }

  // RF 62: Reporte de inventario
  Future<Map<String, dynamic>> getInventoryReport() async {
    final db = await database;
    final products = await db.query('productos');
    final totalProducts = products.length;
    final totalValue = products.fold(0.0, (sum, p) => 
      sum + (((p['stockActual'] ?? 0) as num) * ((p['costoPromedio'] ?? 0) as num)).toDouble());
    final lowStock = products.where((p) => ((p['stockActual'] ?? 0) as num) < ((p['stockMinimo'] ?? 0) as num)).length;
    
    return {
      'total_products': totalProducts,
      'total_value': totalValue,
      'low_stock_count': lowStock,
      'products': products,
    };
  }

  // RF 67: Exportar inventario a CSV
  Future<String> exportInventoryToCSV(List<Map<String, dynamic>> products) async {
    final header = ['Código', 'Nombre', 'Stock', 'Costo', 'Precio', 'Valor'];
    final rows = products.map((p) => [
      (p['codigo'] ?? '').toString(),
      (p['nombre'] ?? '').toString(),
      (p['stockActual'] ?? 0).toString(),
      (p['costoPromedio'] ?? 0).toString(),
      (p['precioVenta'] ?? 0).toString(),
      (((p['stockActual'] ?? 0) as num) * ((p['costoPromedio'] ?? 0) as num)).toDouble().toString(),
    ]).toList();
    
    return [header, ...rows].map((row) => row.join(',')).join('\n');
  }

  // RF 62: Movimientos de productos
  Future<List<Map<String, dynamic>>> getProductMovementsReport({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    
    return await db.rawQuery('''
      SELECT vd.*, p.nombre as producto_nombre, v.fecha
      FROM ventas_detalle vd
      INNER JOIN productos p ON vd.producto_id = p.id
      INNER JOIN ventas v ON vd.venta_id = v.id
      WHERE v.fecha BETWEEN ? AND ?
      ORDER BY v.fecha DESC
    ''', [start.toIso8601String(), end.toIso8601String()]);
  }

  // RF 63: Reporte de ganancias
  Future<List<Map<String, dynamic>>> getProfitReport({DateTime? startDate, DateTime? endDate}) async {
    return await getMarginReport(startDate: startDate, endDate: endDate);
  }

  // RF 64: Compras por proveedor
  Future<List<Map<String, dynamic>>> getPurchasesBySupplierReport({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    
    return await db.rawQuery('''
      SELECT c.*, pr.nombre as proveedor_nombre
      FROM compras c
      LEFT JOIN proveedores pr ON c.proveedor_id = pr.id
      WHERE c.fecha BETWEEN ? AND ?
      ORDER BY c.fecha DESC
    ''', [start.toIso8601String(), end.toIso8601String()]);
  }

  // RF 64: Detalle de ventas
  Future<List<Map<String, dynamic>>> getSalesDetailReport({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    
    return await db.query('ventas',
      where: 'fecha BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'fecha DESC');
  }

  // RF 67: Exportar ventas a CSV
  Future<String> exportSalesToCSV(List<Map<String, dynamic>> sales) async {
    final header = ['Fecha', 'Número', 'Cliente', 'Total', 'Estado'];
    final rows = sales.map((s) => [
      (s['fecha'] ?? '').toString(),
      (s['numero_venta'] ?? '').toString(),
      (s['cliente'] ?? '').toString(),
      (s['total'] ?? 0).toString(),
      (s['estado'] ?? '').toString(),
    ]).toList();
    
    return [header, ...rows].map((row) => row.join(',')).join('\n');
  }
}
