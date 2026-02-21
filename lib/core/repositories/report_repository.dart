import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:nova_aden/core/database/database_helper.dart';
import 'package:nova_aden/core/models/product.dart';
import 'package:nova_aden/core/models/sale.dart';
import 'package:nova_aden/core/models/purchase.dart';
import 'package:nova_aden/core/repositories/product_repository.dart';
import 'package:nova_aden/core/repositories/sale_repository.dart';
import 'package:nova_aden/core/repositories/purchase_repository.dart';
import 'package:nova_aden/core/repositories/inventory_repository.dart';

class ReportRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ProductRepository _productRepo = ProductRepository();
  final SaleRepository _saleRepo = SaleRepository();
  final PurchaseRepository _purchaseRepo = PurchaseRepository();
  final InventoryRepository _inventoryRepo = InventoryRepository();

  /// RF 29: Reporte de inventario completo
  Future<Map<String, dynamic>> getInventoryReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final products = await _productRepo.getAllProducts();
      final valuedStock = await _inventoryRepo.getValuedStock();
      
      final items = products.map((p) => {
        'id': p.id,
        'code': p.code,
        'name': p.name,
        'stock': p.stock,
        'cost': p.cost,
        'price': p.price,
        'value': p.stock * p.cost,
        'margin': p.price - p.cost,
        'isLowStock': p.isLowStock,
      }).toList();
      
      return {
        'generatedAt': DateTime.now(),
        'totalProducts': products.length,
        'totalUnits': valuedStock['totalUnits'] ?? 0,
        'totalValue': valuedStock['totalValue'] ?? 0.0,
        'lowStockCount': products.where((p) => p.isLowStock).length,
        'items': items,
      };
    } catch (e) {
      return {};
    }
  }

  /// RF 30: Movimientos por producto
  Future<Map<String, dynamic>> getProductMovementsReport({
    required int productId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final product = await _productRepo.getProductById(productId);
      if (product == null) return {};

      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      // Obtener ajustes
      final adjustments = await _dbHelper.getAdjustmentsByProduct(productId);
      
      // Obtener ventas del producto (necesitaríamos sale_items filtrados)
      // Por ahora usamos ajustes como referencia
      
      final movements = <Map<String, dynamic>>[];
      
      // Agregar ajustes positivos
      for (final adj in adjustments.where((a) => a.isPositive)) {
        movements.add({
          'date': adj.date,
          'type': 'Entrada',
          'quantity': adj.adjustmentQuantity,
          'reason': adj.reason,
          'reference': adj.adjustmentNumber,
        });
      }
      
      // Agregar ajustes negativos
      for (final adj in adjustments.where((a) => a.isNegative)) {
        movements.add({
          'date': adj.date,
          'type': 'Salida',
          'quantity': adj.adjustmentQuantity.abs(),
          'reason': adj.reason,
          'reference': adj.adjustmentNumber,
        });
      }
      
      // Ordenar por fecha
      movements.sort((a, b) => b['date'].compareTo(a['date']));

      return {
        'product': product,
        'currentStock': product.stock,
        'startDate': start,
        'endDate': end,
        'movements': movements,
        'totalEntries': movements.where((m) => m['type'] == 'Entrada').fold<num>(0, (sum, m) => sum + (m['quantity'] as num)),
        'totalExits': movements.where((m) => m['type'] == 'Salida').fold<num>(0, (sum, m) => sum + (m['quantity'] as num)),
      };
    } catch (e) {
      return {};
    }
  }

  /// RF 31: Reporte de ventas detallado
  Future<Map<String, dynamic>> getSalesDetailReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();
      
      final sales = await _saleRepo.getSalesByDateRange(start, end);
      
      final items = <Map<String, dynamic>>[];
      double totalRevenue = 0;
      double totalDiscount = 0;
      int totalTransactions = 0;
      
      for (final sale in sales) {
        if (sale.status == 'completed') {
          totalRevenue += sale.total;
          totalDiscount += sale.discount;
          totalTransactions++;
          
          final saleDetail = await _saleRepo.getSaleDetail(sale.id!);
          if (saleDetail != null) {
            final saleItems = saleDetail['items'] as List;
            for (final item in saleItems) {
              items.add({
                'saleNumber': sale.saleNumber,
                'date': sale.date,
                'productName': item['product_name'],
                'productCode': item['product_code'],
                'quantity': item['quantity'],
                'unitPrice': item['unit_price'],
                'subtotal': item['subtotal'],
                'customer': sale.customerName ?? 'N/A',
                'paymentType': sale.isPartialPayment ? 'Parcial' : 'Contado',
              });
            }
          }
        }
      }

      return {
        'generatedAt': DateTime.now(),
        'startDate': start,
        'endDate': end,
        'totalTransactions': totalTransactions,
        'totalRevenue': totalRevenue,
        'totalDiscount': totalDiscount,
        'netRevenue': totalRevenue - totalDiscount,
        'items': items,
      };
    } catch (e) {
      return {};
    }
  }

  /// RF 32: Reporte de ganancias
  Future<Map<String, dynamic>> getProfitReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();
      
      final sales = await _saleRepo.getSalesByDateRange(start, end);
      
      double totalRevenue = 0;
      double totalCost = 0;
      
      for (final sale in sales.where((s) => s.status == 'completed')) {
        totalRevenue += sale.total;
        
        // Obtener costo de los productos vendidos
        final saleDetail = await _saleRepo.getSaleDetail(sale.id!);
        if (saleDetail != null) {
          final saleItems = saleDetail['items'] as List;
          for (final item in saleItems) {
            final product = await _productRepo.getProductById(item['product_id']);
            if (product != null) {
              totalCost += product.cost * item['quantity'];
            }
          }
        }
      }
      
      final grossProfit = totalRevenue - totalCost;
      final profitMargin = totalRevenue > 0 ? (grossProfit / totalRevenue) * 100 : 0;

      return {
        'generatedAt': DateTime.now(),
        'startDate': start,
        'endDate': end,
        'totalRevenue': totalRevenue,
        'totalCost': totalCost,
        'grossProfit': grossProfit,
        'profitMargin': profitMargin,
        'transactions': sales.where((s) => s.status == 'completed').length,
      };
    } catch (e) {
      return {};
    }
  }

  /// RF 33: Reporte de compras por proveedor
  Future<Map<String, dynamic>> getPurchasesBySupplierReport({
    DateTime? startDate,
    DateTime? endDate,
    int? supplierId,
  }) async {
    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();
      
      final purchases = await _purchaseRepo.getPurchasesByDateRange(start, end);
      
      // Agrupar por proveedor
      final bySupplier = <String, Map<String, dynamic>>{};
      
      for (final purchase in purchases.where((p) => p.status == 'completed')) {
        final supplierName = purchase.supplierName ?? 'Compra Rápida';
        
        if (!bySupplier.containsKey(supplierName)) {
          bySupplier[supplierName] = {
            'supplierName': supplierName,
            'purchaseCount': 0,
            'totalAmount': 0.0,
            'purchases': [],
          };
        }
        
        bySupplier[supplierName]!['purchaseCount']++;
        bySupplier[supplierName]!['totalAmount'] += purchase.total;
        bySupplier[supplierName]!['purchases'].add({
          'number': purchase.purchaseNumber,
          'date': purchase.date,
          'total': purchase.total,
        });
      }

      return {
        'generatedAt': DateTime.now(),
        'startDate': start,
        'endDate': end,
        'totalSuppliers': bySupplier.length,
        'totalPurchases': purchases.where((p) => p.status == 'completed').length,
        'bySupplier': bySupplier,
      };
    } catch (e) {
      return {};
    }
  }

  /// RF 34: Exportar a CSV (función genérica)
  Future<String> exportToCSV({
    required String fileName,
    required List<Map<String, dynamic>> data,
    required List<String> columns,
    required Map<String, String> columnLabels,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      
      // Encabezados
      final header = columns.map((c) => columnLabels[c] ?? c).join(',');
      
      // Filas
      final rows = data.map((row) {
        return columns.map((c) {
          final value = row[c]?.toString() ?? '';
          // Escapar comas y comillas
          if (value.contains(',') || value.contains('"')) {
            return '"${value.replaceAll('"', '""')}"';
          }
          return value;
        }).join(',');
      }).join('\n');
      
      final csv = '$header\n$rows';
      await file.writeAsString(csv);
      
      return filePath;
    } catch (e) {
      return '';
    }
  }

  /// Exportar reporte de inventario a CSV
  Future<String> exportInventoryToCSV() async {
    final report = await getInventoryReport();
    final items = report['items'] as List<Map<String, dynamic>>;
    
    return await exportToCSV(
      fileName: 'inventario_${DateTime.now().millisecondsSinceEpoch}.csv',
      data: items,
      columns: ['code', 'name', 'stock', 'cost', 'price', 'value'],
      columnLabels: {
        'code': 'Código',
        'name': 'Nombre',
        'stock': 'Stock',
        'cost': 'Costo',
        'price': 'Precio',
        'value': 'Valor',
      },
    );
  }

  /// Exportar reporte de ventas a CSV
  Future<String> exportSalesToCSV(DateTime start, DateTime end) async {
    final report = await getSalesDetailReport(startDate: start, endDate: end);
    final items = report['items'] as List<Map<String, dynamic>>;
    
    return await exportToCSV(
      fileName: 'ventas_${DateTime.now().millisecondsSinceEpoch}.csv',
      data: items,
      columns: ['saleNumber', 'date', 'productName', 'quantity', 'unitPrice', 'subtotal'],
      columnLabels: {
        'saleNumber': 'Número',
        'date': 'Fecha',
        'productName': 'Producto',
        'quantity': 'Cantidad',
        'unitPrice': 'Precio Unit.',
        'subtotal': 'Subtotal',
      },
    );
  }
}
