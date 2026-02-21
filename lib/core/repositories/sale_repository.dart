import 'package:nova_aden/core/models/sale.dart';
import 'package:nova_aden/core/models/sale_item.dart';
import 'package:nova_aden/core/database/database_helper.dart';
import 'package:nova_aden/core/repositories/product_repository.dart';

class SaleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ProductRepository _productRepo = ProductRepository();

  /// RF 13, 14, 15, 16, 18: Registrar venta completa
  Future<bool> registerSale({
    required List<SaleItem> items,
    required double discount,
    required double paid,
    String? customerName,
    String? customerPhone,
    bool isPartialPayment = false,
  }) async {
    try {
      // Validar stock para cada producto
      for (final item in items) {
        final product = await _productRepo.getProductById(item.productId);
        if (product == null || product.stock < item.quantity) {
          return false; // Stock insuficiente
        }
      }

      // Calcular totales
      final subtotal = items.fold<double>(0, (sum, item) => sum + item.subtotal);
      final total = subtotal - discount;
      final change = paid - total;

      // Generar número de venta único
      final saleNumber = 'VTA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

      // Crear venta
      final sale = Sale(
        saleNumber: saleNumber,
        date: DateTime.now(),
        subtotal: subtotal,
        discount: discount,
        total: total,
        paid: paid,
        change: change,
        isPartialPayment: isPartialPayment,
        customerName: customerName,
        customerPhone: customerPhone,
        status: isPartialPayment ? 'pending' : 'completed',
      );

      // Actualizar stock de productos
      for (final item in items) {
        final product = await _productRepo.getProductById(item.productId);
        if (product != null) {
          await _productRepo.updateStock(item.productId, product.stock - item.quantity);
        }
      }

      // Guardar venta con ítems
      return await _dbHelper.createSaleWithItems(sale, items);
    } catch (e) {
      return false;
    }
  }

  /// RF 20: Listar ventas del día
  Future<List<Sale>> getTodaySales() async {
    try {
      return await _dbHelper.getTodaySales();
    } catch (e) {
      return [];
    }
  }

  /// RF 21: Filtrar ventas por fechas
  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
    try {
      return await _dbHelper.getSalesByDateRange(start, end);
    } catch (e) {
      return [];
    }
  }

  /// RF 22: Ver detalle de venta
  Future<Map<String, dynamic>?> getSaleDetail(int saleId) async {
    try {
      final sale = await _dbHelper.getSaleById(saleId);
      if (sale == null) return null;
      
      final items = await _dbHelper.getSaleItems(saleId);
      return {'sale': sale, 'items': items};
    } catch (e) {
      return null;
    }
  }

  /// Estadísticas de ventas
  Future<Map<String, dynamic>> getStats() async {
    try {
      final todayCount = await _dbHelper.getSaleCount();
      final todayTotal = await _dbHelper.getTodaySalesTotal();
      return {'count': todayCount, 'total': todayTotal};
    } catch (e) {
      return {'count': 0, 'total': 0.0};
    }
  }
}
