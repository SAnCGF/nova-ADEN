import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/purchase.dart';
import '../models/product.dart';
import './product_repository.dart';

class PurchaseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ProductRepository _productRepo = ProductRepository();
  Future<Database> get _db async => await _dbHelper.database;

  Future<int> createQuickPurchase(List<PurchaseLine> lines) async {
    final db = await _db;
    double total = 0.0;
    for (var l in lines) {
      total = total + (l.subtotal.toDouble());
    }
    final compraId = await db.insert('compras', {
      'fecha': DateTime.now().toIso8601String(),
      'total': total,
      'estado': 'pendiente',
    });
    for (var line in lines) {
      await db.insert('compras_detalle', {
        'compra_id': compraId,
        'producto_id': line.productoId,
        'cantidad': line.cantidad,
        'costoUnitario': line.costoUnitario,
        'subtotal': line.subtotal,
      });
    }
    return compraId;
  }

  Future<int> createPurchaseWithSupplier(int proveedorId, List<PurchaseLine> lines) async {
    final db = await _db;
    double total = 0.0;
    for (var l in lines) {
      total = total + (l.subtotal.toDouble());
    }
    final compraId = await db.insert('compras', {
      'proveedor_id': proveedorId,
      'fecha': DateTime.now().toIso8601String(),
      'total': total,
      'estado': 'pendiente',
    });
    for (var line in lines) {
      await db.insert('compras_detalle', {
        'compra_id': compraId,
        'producto_id': line.productoId,
        'cantidad': line.cantidad,
        'costoUnitario': line.costoUnitario,
        'subtotal': line.subtotal,
      });
    }
    return compraId;
  }

  Future<int> addLineToPurchase(int compraId, PurchaseLine line) async {
    final db = await _db;
    return await db.insert('compras_detalle', line.toMap());
  }

  Future<int> updatePurchaseLine(int lineId, PurchaseLine line) async {
    final db = await _db;
    return await db.update('compras_detalle', line.toMap(), where: 'id = ?', whereArgs: [lineId]);
  }

  Future<int> deletePurchaseLine(int lineId) async {
    final db = await _db;
    return await db.delete('compras_detalle', where: 'id = ?', whereArgs: [lineId]);
  }

  Future<bool> confirmPurchase(int compraId) async {
    final db = await _db;
    final lines = await db.query('compras_detalle', where: 'compra_id = ?', whereArgs: [compraId]);
    for (var line in lines) {
      final producto = await _productRepo.getProductById(line['producto_id'] as int);
      if (producto != null) {
        final stockActual = producto.stockActual;
        final costoActual = producto.costo;
        final nuevaCantidad = line['cantidad'] as int;
        final nuevoCosto = (line['costoUnitario'] as num).toDouble();
        final totalStock = stockActual + nuevaCantidad;
        final totalValor = (stockActual * costoActual) + (nuevaCantidad * nuevoCosto);
        final costoPromedio = totalStock > 0 ? totalValor / totalStock : nuevoCosto;
        await _productRepo.updateProduct(producto.id!, Product(
          nombre: producto.nombre,
          codigo: producto.codigo,
          costo: costoPromedio,
          precioVenta: producto.precioVenta,
          stockActual: totalStock,
          stockMinimo: producto.stockMinimo,
          unidadMedida: producto.unidadMedida,
          categoria: producto.categoria,
        ));
      }
    }
    await db.update('compras', {'estado': 'confirmada'}, where: 'id = ?', whereArgs: [compraId]);
    return true;
  }

  Future<List<Map<String, dynamic>>> getPurchases({DateTime? desde, DateTime? hasta, int? proveedorId}) async {
    final db = await _db;
    String where = '1=1';
    List<dynamic> args = [];
    if (desde != null) { where += ' AND fecha >= ?'; args.add(desde.toIso8601String()); }
    if (hasta != null) { where += ' AND fecha <= ?'; args.add(hasta.toIso8601String()); }
    if (proveedorId != null) { where += ' AND proveedor_id = ?'; args.add(proveedorId); }
    return await db.query('compras', where: where, whereArgs: args, orderBy: 'fecha DESC');
  }

  Future<List<PurchaseLine>> getPurchaseLines(int compraId) async {
    final db = await _db;
    final results = await db.query('compras_detalle', where: 'compra_id = ?', whereArgs: [compraId]);
    return results.map((map) => PurchaseLine.fromMap(map)).toList();
  }
}
