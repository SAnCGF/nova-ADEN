import 'package:nova_aden/core/models/inventory_adjustment.dart';
import 'package:nova_aden/core/models/inventory_loss.dart';
import 'package:nova_aden/core/models/loss_reason.dart';
import 'package:nova_aden/core/database/database_helper.dart';
import 'package:nova_aden/core/repositories/product_repository.dart';

class InventoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ProductRepository _productRepo = ProductRepository();

  /// Inicializar motivos de merma (RF 27)
  Future<void> initializeReasons() async {
    await _dbHelper.initializeLossReasons();
  }

  /// Obtener motivos de merma (RF 27)
  Future<List<LossReason>> getLossReasons() async {
    try {
      return await _dbHelper.getAllLossReasons();
    } catch (e) {
      return LossReason.getPredefinedReasons();
    }
  }

  /// RF 23: Stock valorado total
  Future<Map<String, dynamic>> getValuedStock() async {
    try {
      return await _dbHelper.getValuedStock();
    } catch (e) {
      return {'productCount': 0, 'totalUnits': 0, 'totalValue': 0.0, 'avgCost': 0.0};
    }
  }

  /// RF 23: Stock valorado por producto
  Future<List<Map<String, dynamic>>> getValuedStockByProduct() async {
    try {
      return await _dbHelper.getValuedStockByProduct();
    } catch (e) {
      return [];
    }
  }

  /// RF 24: Ajuste positivo de inventario
  Future<bool> registerPositiveAdjustment({
    required int productId,
    required String productName,
    required String productCode,
    required int quantity,
    required String reason,
    String? notes,
  }) async {
    try {
      final product = await _productRepo.getProductById(productId);
      if (product == null) return false;

      final quantityBefore = product.stock;
      final quantityAfter = quantityBefore + quantity;
      final totalValue = quantity * product.cost;

      final adjustment = InventoryAdjustment(
        adjustmentNumber: 'AJT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        date: DateTime.now(),
        productId: productId,
        productName: productName,
        productCode: productCode,
        quantityBefore: quantityBefore,
        quantityAfter: quantityAfter,
        adjustmentQuantity: quantity,
        type: 'positive',
        reason: reason,
        notes: notes,
        unitCost: product.cost,
        totalValue: totalValue,
      );

      await _dbHelper.createAdjustment(adjustment);
      await _productRepo.updateStock(productId, quantityAfter);
      
      return true;
    } catch (e) {
      print('Error en ajuste positivo: $e');
      return false;
    }
  }

  /// RF 25: Ajuste negativo de inventario
  Future<bool> registerNegativeAdjustment({
    required int productId,
    required String productName,
    required String productCode,
    required int quantity,
    required String reason,
    String? notes,
  }) async {
    try {
      final product = await _productRepo.getProductById(productId);
      if (product == null) return false;
      if (product.stock < quantity) return false; // Stock insuficiente

      final quantityBefore = product.stock;
      final quantityAfter = quantityBefore - quantity;
      final totalValue = quantity * product.cost;

      final adjustment = InventoryAdjustment(
        adjustmentNumber: 'AJT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        date: DateTime.now(),
        productId: productId,
        productName: productName,
        productCode: productCode,
        quantityBefore: quantityBefore,
        quantityAfter: quantityAfter,
        adjustmentQuantity: -quantity,
        type: 'negative',
        reason: reason,
        notes: notes,
        unitCost: product.cost,
        totalValue: totalValue,
      );

      await _dbHelper.createAdjustment(adjustment);
      await _productRepo.updateStock(productId, quantityAfter);
      
      return true;
    } catch (e) {
      print('Error en ajuste negativo: $e');
      return false;
    }
  }

  /// RF 26, 27: Registrar merma (individual o masiva)
  Future<bool> registerLoss({
    required int productId,
    required String productName,
    required String productCode,
    required int quantity,
    required String reasonId,
    required String reasonName,
    String? notes,
  }) async {
    try {
      final product = await _productRepo.getProductById(productId);
      if (product == null) return false;
      if (product.stock < quantity) return false;

      final quantityBefore = product.stock;
      final quantityAfter = quantityBefore - quantity;
      final totalValue = quantity * product.cost;

      final loss = InventoryLoss(
        lossNumber: 'MRM-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        date: DateTime.now(),
        productId: productId,
        productName: productName,
        productCode: productCode,
        quantity: quantity,
        unitCost: product.cost,
        totalValue: totalValue,
        reasonId: reasonId,
        reasonName: reasonName,
        notes: notes,
      );

      await _dbHelper.createLoss(loss);
      await _productRepo.updateStock(productId, quantityAfter);
      
      return true;
    } catch (e) {
      print('Error en merma: $e');
      return false;
    }
  }

  /// RF 26: Registrar mermas masivas
  Future<bool> registerMassLoss(List<Map<String, dynamic>> losses) async {
    try {
      for (final lossData in losses) {
        final success = await registerLoss(
          productId: lossData['productId'],
          productName: lossData['productName'],
          productCode: lossData['productCode'],
          quantity: lossData['quantity'],
          reasonId: lossData['reasonId'],
          reasonName: lossData['reasonName'],
          notes: lossData['notes'],
        );
        if (!success) return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// RF 28: Listar mermas con filtros
  Future<List<InventoryLoss>> getLosses({
    DateTime? startDate,
    DateTime? endDate,
    String? reasonId,
  }) async {
    try {
      if (reasonId != null) {
        return await _dbHelper.getLossesByReason(reasonId);
      }
      
      if (startDate != null && endDate != null) {
        return await _dbHelper.getLossesByDateRange(startDate, endDate);
      }
      
      // Últimos 30 días por defecto
      final end = DateTime.now();
      final start = end.subtract(const Duration(days: 30));
      return await _dbHelper.getLossesByDateRange(start, end);
    } catch (e) {
      return [];
    }
  }

  /// Listar ajustes
  Future<List<InventoryAdjustment>> getAdjustments({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (startDate != null && endDate != null) {
        return await _dbHelper.getAdjustmentsByDateRange(startDate, endDate);
      }
      
      final end = DateTime.now();
      final start = end.subtract(const Duration(days: 30));
      return await _dbHelper.getAdjustmentsByDateRange(start, end);
    } catch (e) {
      return [];
    }
  }

  /// Estadísticas de mermas
  Future<Map<String, dynamic>> getLossStats(DateTime start, DateTime end) async {
    try {
      final losses = await getLosses(startDate: start, endDate: end);
      final totalValue = losses.fold<double>(0, (sum, l) => sum + l.totalValue);
      
      // Agrupar por motivo
      final byReason = <String, double>{};
      for (final loss in losses) {
        byReason[loss.reasonName] = (byReason[loss.reasonName] ?? 0) + loss.totalValue;
      }
      
      return {
        'count': losses.length,
        'totalValue': totalValue,
        'byReason': byReason,
      };
    } catch (e) {
      return {'count': 0, 'totalValue': 0.0, 'byReason': {}};
    }
  }
}
