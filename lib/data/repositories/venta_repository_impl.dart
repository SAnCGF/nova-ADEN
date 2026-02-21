import '../../domain/repositories/venta_repository.dart';
import '../datasources/venta_database.dart';

class VentaRepositoryImpl implements VentaRepository {
  final VentaDatabase database;

  VentaRepositoryImpl({required this.database});

  @override
  Future<List<Map<String, dynamic>>> getAllVentas() async {
    return await database.getAllVentas();
  }

  @override
  Future<List<Map<String, dynamic>>> getVentasByDateRange(DateTime start, DateTime end) async {
    final db = await database.database;
    return await db.query(
      'ventas',
      where: 'fecha BETWEEN ? AND ? AND estado = 1',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'fecha DESC',
    );
  }

  @override
  Future<int> createVenta(Map<String, dynamic> venta, List<Map<String, dynamic>> detalles) async {
    final db = await database.database;
    int ventaId = 0;

    await db.transaction((txn) async {
      ventaId = await txn.insert('ventas', venta);
      for (var detalle in detalles) {
        detalle['venta_id'] = ventaId;
        await txn.insert('detalle_ventas', detalle);
      }
    });

    return ventaId;
  }

  @override
  Future<bool> cancelVenta(int id) async {
    final db = await database.database;
    final result = await db.update('ventas', {'estado': 0}, where: 'id = ?', whereArgs: [id]);
    return result > 0;
  }

  @override
  Future<double> getTotalVentasByDateRange(DateTime start, DateTime end) async {
    final db = await database.database;
    final result = await db.rawQuery(
      'SELECT SUM(total) as total FROM ventas WHERE fecha BETWEEN ? AND ? AND estado = 1',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return result.first['total'] as double? ?? 0.0;
  }
}
