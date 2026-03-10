import '../models/product.dart';

class StockAlertService {
  // RF 68: Verificar productos con stock bajo
  static List<Product> getLowStockProducts(List<Product> products, {int threshold = 10}) {
    return products.where((p) => p.stockActual <= p.stockMinimo).toList();
  }

  // Verificar productos próximos a vencer (si hay fecha_vencimiento)
  static List<Product> getExpiringProducts(List<Product> products, {int days = 7}) {
    final now = DateTime.now();
    final threshold = now.add(Duration(days: days));
    // Implementar cuando se agregue fecha_vencimiento a Product
    return [];
  }

  // Generar mensaje de alerta
  static String generateAlertMessage(List<Product> lowStockProducts) {
    if (lowStockProducts.isEmpty) return '✅ Todo el stock está en niveles adecuados';
    
    final count = lowStockProducts.length;
    return '⚠️ $count productos con stock bajo:\n' +
        lowStockProducts.map((p) => '• ${p.nombre}: ${p.stockActual} unidades').join('\n');
  }
}
