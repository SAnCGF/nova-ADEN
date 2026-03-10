import 'package:flutter/material.dart';
import 'package:nova_aden/core/repositories/report_repository.dart';
import './inventory_report_page.dart';
import './sales_report_page.dart';
import './profit_report_page.dart';
import './purchases_report_page.dart';
import './product_movements_report_page.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildReportTile(context, 'Inventario', Icons.inventory_2, Colors.blue, () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InventoryReportPage()),
            )),
            _buildReportTile(context, 'Ventas', Icons.receipt_long, Colors.green, () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SalesReportPage()),
            )),
            _buildReportTile(context, 'Ganancias', Icons.trending_up, Colors.purple, () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfitReportPage()),
            )),
            _buildReportTile(context, 'Compras', Icons.shopping_cart, Colors.orange, () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PurchasesReportPage()),
            )),
            _buildReportTile(context, 'Movimientos', Icons.swap_horiz, Colors.teal, () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProductMovementsReportPage()),
            )),
            _buildReportTile(context, 'Exportar CSV', Icons.download, Colors.indigo, () {
              // Simular exportación
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📊 Exportando todos los datos a CSV...')),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Ver reporte', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
