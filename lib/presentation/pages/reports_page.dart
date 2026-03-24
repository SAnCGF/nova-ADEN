import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes'), centerTitle: true),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _reportCard('Inventario', Icons.inventory_2, Colors.blue),
          _reportCard('Ventas', Icons.receipt_long, Colors.green),
          _reportCard('Compras', Icons.shopping_bag, Colors.orange),
          _reportCard('Ganancias', Icons.trending_up, Colors.purple),
          _reportCard('Productos', Icons.bar_chart, Colors.teal),
          _reportCard('Exportar CSV', Icons.download, Colors.indigo),
        ],
      ),
    );
  }

  Widget _reportCard(String t, IconData i, Color c) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(i, size: 48, color: c), const SizedBox(height: 8), Text(t)],
      ),
    );
  }
}
