import 'package:nova_aden/core/models/purchase.dart';
import 'package:nova_aden/core/models/purchase_item.dart';
import 'package:nova_aden/core/models/supplier.dart';
import 'package:nova_aden/core/database/database_helper.dart';
import 'package:nova_aden/core/repositories/product_repository.dart';

class PurchaseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ProductRepository _productRepo = ProductRepository();

  /// RF 7: Registrar proveedor
  Future<bool> createSupplier(Supplier supplier) async {
    try {
      await _dbHelper.createSupplier(supplier);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtener todos los proveedores
  Future<List<Supplier>> getAllSuppliers() async {
    try {
      return await _dbHelper.getAllSuppliers();
    } catch (e) {
      return [];
    }
  }

  /// RF 6, 7, 8, 9, 10: Registrar compra completa
  Future<bool> registerPurchase({
    required List<PurchaseItem> items,
    int? supplierId,
    String? supplierName,
    bool isQuickPurchase = false,
  }) async {
    try {
      if (items.isEmpty) return false;

      // Calcular totales
      final subtotal = items.fold<double>(0, (sum, item) => sum + item.subtotal);
      final total = subtotal; // Sin impuestos por ahora

      // Generar número de compra único
      final purchaseNumber = 'CMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

      // Crear compra
      final purchase = Purchase(
        purchaseNumber: purchaseNumber,
        date: DateTime.now(),
        supplierId: isQuickPurchase ? null : supplierId,
        supplierName: isQuickPurchase ? 'Compra Rápida' : supplierName,
        subtotal: subtotal,
        total: total,
        status: 'completed',
      );

      // Actualizar stock y costo promedio ponderado (CPP)
      for (final item in items) {
        final product = await _productRepo.getProductById(item.productId);
        if (product != null) {
          final newStock = product.stock + item.quantity;
          // Fórmula CPP: ((costo_actual * stock_actual) + (costo_compra * cantidad_compra)) / nuevo_stock
          final newAvgCost = ((product.cost * product.stock) + (item.unitCost * item.quantity)) / newStock;
          await _productRepo.updateStock(item.productId, newStock);
          
          // Actualizar costo del producto
          final db = await _dbHelper.database;
          await db.update(
            'products',
            {'cost': newAvgCost, 'updated_at': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [item.productId],
          );
        }
      }

      // Guardar compra con ítems
      return await _dbHelper.createPurchaseWithItems(purchase, items, updateStock: false);
    } catch (e) {
      print('Error en registerPurchase: $e');
      return false;
    }
  }

  /// RF 11: Listar compras por fecha
  Future<List<Purchase>> getPurchasesByDateRange(DateTime start, DateTime end) async {
    try {
      return await _dbHelper.getPurchasesByDateRange(start, end);
    } catch (e) {
      return [];
    }
  }

  /// Obtener compras del día
  Future<List<Purchase>> getTodayPurchases() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return await getPurchasesByDateRange(start, end);
  }

  /// Obtener detalle de compra
  Future<Map<String, dynamic>?> getPurchaseDetail(int purchaseId) async {
    try {
      final db = await _dbHelper.database;
      final purchaseResults = await db.query(
        'purchases',
        where: 'id = ?',
        whereArgs: [purchaseId],
        limit: 1,
      );
      if (purchaseResults.isEmpty) return null;
      
      final purchase = Purchase.fromMap(purchaseResults.first);
      final items = await _dbHelper.getPurchaseItems(purchaseId);
      
      return {'purchase': purchase, 'items': items};
    } catch (e) {
      return null;
    }
  }

  /// Estadísticas de compras
  Future<Map<String, dynamic>> getStats() async {
    try {
      final db = await _dbHelper.database;
      final count = await db.rawQuery('SELECT COUNT(*) FROM purchases');
      final total = await db.rawQuery('SELECT SUM(total) FROM purchases');
      return {
        'count': count.first.values.first ?? 0,
        'total': total.first.values.first ?? 0.0,
      };
    } catch (e) {
      return {'count': 0, 'total': 0.0};
    }
  }
}
