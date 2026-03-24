import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/sale.dart';
import '../models/product.dart';
import './product_repository.dart';

class SaleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ProductRepository _productRepo = ProductRepository();
  Future<Database> get _db async => await _dbHelper.database;

  // RF 13-16: Crear venta con líneas
  Future<int> createSale(int? clienteId, List<SaleLine> lines) async {
    final db = await _db;
    double total = 0.0;
    for (var l in lines) {
      total = total + l.subtotal;
    }
    
    final ventaId = await db.insert('ventas', {
      'cliente_id': clienteId,
      'fecha': DateTime.now().toIso8601String(),
      'total': total,
      'estado': 'pagado',
    });

    for (var line in lines) {
      await db.insert('ventas_detalle', {
        'venta_id': ventaId,
        'producto_id': line.productoId,
        'cantidad': line.cantidad,
        'precioUnitario': line.precioUnitario,
        'subtotal': line.subtotal,
      });

      // Actualizar stock del producto
      final producto = await _productRepo.getProductById(line.productoId);
      if (producto != null) {
        await _productRepo.updateProduct(producto.id!, Product(
          nombre: producto.nombre,
          codigo: producto.codigo,
          costo: producto.costo,
          precioVenta: producto.precioVenta,
          stockActual: producto.stockActual - line.cantidad,
          stockMinimo: producto.stockMinimo,
          unidadMedida: producto.unidadMedida,
          categoria: producto.categoria,
        ));
      }
    }
    return ventaId;
  }

  // RF 11: Listar ventas con filtros
  Future<List<Map<String, dynamic>>> getSales({DateTime? desde, DateTime? hasta, int? clienteId}) async {
    final db = await _db;
    String where = '1=1';
    List<dynamic> args = [];
    if (desde != null) { where += ' AND fecha >= ?'; args.add(desde.toIso8601String()); }
    if (hasta != null) { where += ' AND fecha <= ?'; args.add(hasta.toIso8601String()); }
    if (clienteId != null) { where += ' AND cliente_id = ?'; args.add(clienteId); }
    return await db.query('ventas', where: where, whereArgs: args, orderBy: 'fecha DESC');
  }

  Future<List<SaleLine>> getSaleLines(int ventaId) async {
    final db = await _db;
    final results = await db.query('ventas_detalle', where: 'venta_id = ?', whereArgs: [ventaId]);
    return results.map((map) => SaleLine.fromMap(map)).toList();
  }
}
