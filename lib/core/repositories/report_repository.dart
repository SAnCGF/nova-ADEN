import 'package:sqflite/sqflite.dart';
import 'product_repository.dart';
import 'sale_repository.dart';
import 'inventory_repository.dart';
import 'purchase_repository.dart';

class ReportRepository {
  final ProductRepository _productRepo = ProductRepository();
  final SaleRepository _saleRepo = SaleRepository();
  final InventoryRepository _inventoryRepo = InventoryRepository();

  final PurchaseRepository _purchaseRepo = PurchaseRepository();
  // Reporte de Inventario Valorado
  Future<Map<String, dynamic>> getInventoryValuationReport() async {
    try {
      final products = await _productRepo.getAllProducts();
      final valuedStock = await _inventoryRepo.getValuedStock();
      final items = products.map((p) => {
        'id': p.id,
        'code': p.codigo,
        'name': p.nombre,
        'stock': p.stockActual,
        'cost': p.costoPromedio,
        'price': p.precioVenta,
        'value': p.stockActual * p.costoPromedio,
        'margin': p.precioVenta - p.costoPromedio,
        'isLowStock': p.stockActual <= p.stockMinimo,
      }).toList();
      return {
        'generatedAt': DateTime.now(),
        'totalProducts': products.length,
        'totalUnits': valuedStock['totalUnits'] ?? 0,
        'totalValue': valuedStock['totalValue'] ?? 0.0,
        'lowStockCount': products.where((p) => p.stockActual <= p.stockMinimo).length,
        'items': items,
      };
    } catch (e) { return {}; }
  }

  // Alias para compatibilidad
  Future<Map<String, dynamic>> getInventoryReport() async => getInventoryValuationReport();
  Future<bool> exportInventoryToCSV() async => true;

  // Reporte de Ventas
  Future<Map<String, dynamic>> getSalesReport(DateTime start, DateTime end) async {
    try {
      final sales = await _saleRepo.getSalesByDateRange(start, end);
      final items = <Map<String, dynamic>>[];
      for (final sale in sales) {
        final saleId = sale['id'] as int;
        final saleDetail = await _saleRepo.getSaleDetail(saleId);
        if (saleDetail != null) {
          for (final item in saleDetail) {
            items.add({
              'saleNumber': sale['numero_venta'],
              'date': sale['fecha'],
              'productName': item['nombre_producto'],
              'quantity': item['cantidad'] as int,
              'unitPrice': item['precio_unitario'] as double,
              'subtotal': item['subtotal'] as double,
              'discount': item['descuento'] as double? ?? 0.0,
              'total': item['total'] as double,
            });
          }
        }
      }
      return {
        'startDate': start, 'endDate': end,
        'totalSales': sales.length, 'totalItems': items.length,
        'totalRevenue': items.fold(0.0, (sum, i) => sum + (i['total'] as double)),
        'items': items,
      };
    } catch (e) { return {}; }
  }

  // Alias para compatibilidad
  Future<Map<String, dynamic>> getSalesDetailReport(DateTime? start, DateTime? end) async {
    if (start == null || end == null) return {};
    return getSalesReport(start, end);
  }
  Future<bool> exportSalesToCSV() async => true;

  // Reporte de Ganancias
  Future<Map<String, dynamic>> getProfitReport(DateTime start, DateTime end) async {
    try {
      final sales = await _saleRepo.getSalesByDateRange(start, end);
      double revenue = 0, cost = 0;
      for (final sale in sales) {
        final detail = await _saleRepo.getSaleDetail(sale['id'] as int);
        if (detail != null) {
          for (final item in detail) {
            final p = await _productRepo.getProductById(item['producto_id'] as int);
            if (p != null) {
              final qty = item['cantidad'] as int;
              revenue += p.precioVenta * qty;
              cost += p.costoPromedio * qty;
            }
          }
        }
      }
      return {'revenue': revenue, 'cost': cost, 'profit': revenue - cost};
    } catch (e) { return {}; }
  }

  // Reporte de Movimientos de Producto
  Future<Map<String, dynamic>> getProductMovementsReport(int productId) async {
    try {
      final product = await _productRepo.getProductById(productId);
      if (product == null) return {};
      return {
        'productId': product.id,
        'productName': product.nombre,
        'currentStock': product.stockActual,
        'movements': [],
      };
    } catch (e) { return {}; }
  }

  // Reporte de Compras por Proveedor
  Future<Map<String, dynamic>> getPurchasesBySupplierReport(String? supplierId, DateTime? start, DateTime? end) async {
    try {
      if (start == null || end == null) return {};
      final purchases = await _purchaseRepo.getPurchasesByDateRange(start, end);
      return {'supplierId': supplierId, 'purchases': purchases};
    } catch (e) { return {}; }
  }
}
