import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/repositories/inventory_repository.dart';
import '../../core/repositories/sale_repository.dart';
import '../../core/repositories/product_repository.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final _inventoryRepo = InventoryRepository();
  final _saleRepo = SaleRepository();
  final _productRepo = ProductRepository();
  bool _loading = false;
  DateTime? _reportStart;
  DateTime? _reportEnd;

  Future<void> _showReport(String title, Widget content) async {
    await showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SizedBox(width: 400, height: 500, child: content),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Filtro de fechas global
          Card(
            child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
              const Text('📅 Filtro de Fechas', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: ElevatedButton.icon(onPressed: () async { final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now()); if (d != null) setState(() => _reportStart = d); }, icon: const Icon(Icons.calendar_today), label: const Text('Desde'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton.icon(onPressed: () async { final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now()); if (d != null) setState(() => _reportEnd = d); }, icon: const Icon(Icons.calendar_today), label: const Text('Hasta'))),
              ]),
            ])),
          ),
          const SizedBox(height: 24),
          
          // RF 29: Reporte de Inventario
          _reportCard('📦 Inventario', 'Valoración de stock actual', Icons.inventory_2, Colors.blue, () async {
            setState(() => _loading = true);
            final report = await _inventoryRepo.getInventoryReport();
            setState(() => _loading = false);
            _showReport('Reporte de Inventario', SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _statRow('Total Productos', '${report['totalProductos']}', Colors.blue),
                _statRow('Stock Total', '${report['totalStock']} unidades', Colors.green),
                _statRow('Valor Total', '\$${(report['valorTotal'] as num).toStringAsFixed(2)}', Colors.purple),
                _statRow('Alertas Stock Bajo', '${report['alertasStock']}', Colors.orange),
                const Divider(),
                const Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(report['productos'] as List).map((p) => ListTile(
                  title: Text(p['nombre']),
                  subtitle: Text('Stock: ${p['stock_actual']} | Valor: \$${((p['costo'] as num) * (p['stock_actual'] as int)).toStringAsFixed(2)}'),
                )).toList(),
              ]),
            ));
          }),
          
          // RF 30: Movimientos por Producto
          _reportCard('📊 Movimientos por Producto', 'Historial de entradas/salidas', Icons.swap_horiz, Colors.teal, () async {
            final products = await _productRepo.getAllProducts();
            _showReport('Movimientos por Producto', SingleChildScrollView(
              child: Column(children: products.map((p) => ExpansionTile(
                title: Text(p.nombre),
                subtitle: Text('Stock actual: ${p.stockActual}'),
                children: [FutureBuilder(
                  future: _inventoryRepo.getProductMovements(p.id!),
                  builder: (ctx, snap) => snap.hasData ? Column(children: (snap.data as List).map((m) => ListTile(
                    title: Text(m['tipo']?.toString().toUpperCase() ?? 'MOVIMIENTO'),
                    subtitle: Text('📅 ${m['fecha']?.toString().split('T')[0] ?? ''}'),
                    trailing: Text('${m['cantidad']} u. @ \$${(m['costo'] ?? m['precio_unitario'] ?? 0).toStringAsFixed(2)}'),
                  )).toList()) : const CircularProgressIndicator(),
                )],
              )).toList()),
            ));
          }),
          
          // RF 31: Ventas Detallado
          _reportCard('🧾 Ventas Detallado', 'Listado completo de ventas', Icons.receipt_long, Colors.green, () async {
            setState(() => _loading = true);
            final report = await _saleRepo.getDetailedSalesReport(start: _reportStart, end: _reportEnd);
            setState(() => _loading = false);
            _showReport('Reporte de Ventas', SingleChildScrollView(
              child: Column(children: report.map((v) => Card(child: ListTile(
                title: Text('Venta #${v['id']}'),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('📅 ${v['fecha']?.toString().split('T')[0]}'),
                  Text('👤 ${v['cliente'] ?? 'General'}'),
                  Text('📦 ${v['productos']}'),
                  Text('💰 Total: \$${(v['total'] as num).toStringAsFixed(2)}'),
                  if (v['es_fiado'] == 1) const Text('⚠️ Fiado', style: TextStyle(color: Colors.orange)),
                ]),
              ))).toList()),
            ));
          }),
          
          // RF 32: Ganancias
          _reportCard('💰 Ganancias', 'Análisis de rentabilidad', Icons.trending_up, Colors.purple, () async {
            setState(() => _loading = true);
            final report = await _saleRepo.getProfitReport(start: _reportStart, end: _reportEnd);
            setState(() => _loading = false);
            _showReport('Reporte de Ganancias', SingleChildScrollView(
              child: Column(children: [
                _statRow('Ingresos Totales', '\$${(report['ingresos'] as num).toStringAsFixed(2)}', Colors.green),
                _statRow('Costos Totales', '\$${(report['costos'] as num).toStringAsFixed(2)}', Colors.red),
                _statRow('Ganancia Neta', '\$${(report['ganancia'] as num).toStringAsFixed(2)}', (report['ganancia'] as num) >= 0 ? Colors.green : Colors.red),
                _statRow('Margen de Ganancia', '${(report['margen'] as num).toStringAsFixed(1)}%', Colors.blue),
                _statRow('Total Ventas', '${report['ventas']}', Colors.teal),
              ]),
            ));
          }),
          
          // RF 33: Compras por Proveedor
          _reportCard('🏭 Compras por Proveedor', 'Inversión por proveedor', Icons.business, Colors.brown, () async {
            // Simplificado: mostrar placeholder
            _showReport('Compras por Proveedor', const Center(child: Text('🚧 Funcionalidad en desarrollo\n\nSeleccione un proveedor para ver su historial de compras.')));
          }),
        ]),
      ),
    );
  }

  Widget _reportCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(child: ListTile(
      leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: _loading ? null : onTap,
    ));
  }

  Widget _statRow(String label, String value, Color color) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 16)),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    ]));
  }
}
