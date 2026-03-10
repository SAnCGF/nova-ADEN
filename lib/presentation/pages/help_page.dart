import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            '📦 Inventario',
            [
              '• Crea productos con código único',
              '• Define stock mínimo para alertas',
              '• Categoriza tus productos',
              '• Archiva productos inactivos',
            ],
          ),
          _buildSection(
            '🛒 Punto de Venta',
            [
              '• Busca productos por nombre o código',
              '• Agrega clientes a la venta',
              '• Marca ventas como fiadas',
              '• Pausa y retoma ventas',
            ],
          ),
          _buildSection(
            '📊 Reportes',
            [
              '• Rotación de productos',
              '• Margen por producto',
              '• Flujo de caja',
              '• Exporta a CSV',
            ],
          ),
          _buildSection(
            '⚙️ Configuración',
            [
              '• Cambia tema claro/oscuro',
              '• Configura impuestos',
              '• Realiza backups',
              '• Bloquea operaciones antiguas',
            ],
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              '¿Necesitas más ayuda?\nsoporte@nova-aden.com',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(item, style: const TextStyle(fontSize: 14)),
            )),
          ],
        ),
      ),
    );
  }
}
