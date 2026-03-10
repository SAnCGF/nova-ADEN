import 'package:flutter/material.dart';
import '../../core/models/product.dart';

class StockAlertWidget extends StatelessWidget {
  final List<Product> products;
  
  const StockAlertWidget({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    // Filtrar productos con stock bajo
    final lowStockProducts = products.where((p) {
      final stock = p.stockActual;
      final min = p.stockMinimo;
      return stock != null && min != null && stock <= min;
    }).toList();
    
    if (lowStockProducts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: Text('✅ Todo el stock está en niveles adecuados')),
      );
    }
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  '$lowStockProducts productos con stock bajo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange.shade700),
                ),
              ],
            ),
            const Divider(height: 16),
            ...lowStockProducts.map((product) => ListTile(
              leading: CircleAvatar(backgroundColor: Colors.red[50], child: Text('${product.stockActual ?? 0}')),
              title: Text(product.nombre ?? ''),
              subtitle: Text('Mín: ${product.stockMinimo ?? 0}'),
              trailing: Text('\$${(product.precioVenta ?? 0.0).toStringAsFixed(2)}'),
            )),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text('Reponer Inventario'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade600, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
