import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Panel de Control', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Cards de indicadores
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _statCard('📦 Productos', 'Ver', Icons.inventory, Colors.blue, () {}),
                _statCard('⚠️ Stock Bajo', 'Ver', Icons.warning, Colors.orange, () {}),
                _statCard('💰 Ventas Hoy', '\$0', Icons.shopping_cart, Colors.green, () {}),
                _statCard('🛒 Compras', 'Ver', Icons.add_shopping_cart, Colors.purple, () {}),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Accesos Rápidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _quickBtn('Nueva Venta', Icons.point_of_sale, Colors.blue),
                _quickBtn('Nuevo Producto', Icons.add, Colors.green),
                _quickBtn('Nueva Compra', Icons.shopping_cart, Colors.orange),
                _quickBtn('Reportes', Icons.bar_chart, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickBtn(String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
    );
  }
}
