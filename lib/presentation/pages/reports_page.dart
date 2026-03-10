import 'package:flutter/material.dart';
import 'package:nova_aden/presentation/pages/product_movements_report_page.dart';
import 'package:nova_aden/presentation/pages/inventory_report_page.dart';
import 'package:nova_aden/presentation/pages/product_movements_report_page.dart';
import 'package:nova_aden/presentation/pages/sales_report_page.dart';
import 'package:nova_aden/presentation/pages/product_movements_report_page.dart';
import 'package:nova_aden/presentation/pages/profit_report_page.dart';
import 'package:nova_aden/presentation/pages/product_movements_report_page.dart';
import 'package:nova_aden/presentation/pages/purchases_report_page.dart';
import 'package:nova_aden/presentation/pages/product_movements_report_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
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
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildReportCard(
              context,
              title: 'Inventario',
              subtitle: 'Stock valorado',
              icon: Icons.inventory_2,
              color: Colors.blue,
              page: const InventoryReportPage(),
            ),
            _buildReportCard(
              context,
              title: 'Ventas',
              subtitle: 'Detalle completo',
              icon: Icons.receipt_long,
              color: Colors.green,
              page: const SalesReportPage(),
            ),
            _buildReportCard(
              context,
              title: 'Ganancias',
              subtitle: 'Rentabilidad',
              icon: Icons.trending_up,
              color: Colors.purple,
              page: const ProfitReportPage(),
            ),
            _buildReportCard(
              context,
              title: 'Compras',
              subtitle: 'Por proveedor',
              icon: Icons.shopping_cart,
              color: Colors.orange,
              page: const PurchasesReportPage(),
            ),
            _buildReportCard(
              context,
              title: 'Movimientos',
              subtitle: 'Por producto',
              icon: Icons.swap_horiz,
              color: Colors.teal,
              page: const ProductMovementsReportPage(),
            ),
            _buildReportCard(
              context,
              title: 'Exportar CSV',
              subtitle: 'Todos los datos',
              icon: Icons.file_download,
              color: Colors.indigo,
              onTap: () => _showExportOptions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    Widget? page,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap ?? () {
          if (page != null) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.7)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Exportar Datos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2, color: Colors.blue),
              title: const Text('Inventario'),
              subtitle: const Text('Todos los productos'),
              onTap: () {
                Navigator.pop(ctx);
                _showSnackBar('Exportando inventario...');
                // Implementar exportación
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.green),
              title: const Text('Ventas'),
              subtitle: const Text('Últimos 30 días'),
              onTap: () {
                Navigator.pop(ctx);
                _showSnackBar('Exportando ventas...');
                // Implementar exportación
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
