import 'package:flutter/material.dart';
import 'package:nova_aden/core/repositories/report_repository.dart';
import 'package:intl/intl.dart';

class InventoryReportPage extends StatefulWidget {
  const InventoryReportPage({super.key});

  @override
  State<InventoryReportPage> createState() => _InventoryReportPageState();
}

class _InventoryReportPageState extends State<InventoryReportPage> {
  final ReportRepository _repository = ReportRepository();
  Map<String, dynamic> _report = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    _report = await _repository.getInventoryReport();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReport,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportCSV(),
            tooltip: 'Exportar CSV',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _report.isEmpty
              ? const Center(child: Text('No hay datos disponibles'))
              : Column(
                  children: [
                    // Resumen
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A5F), Color(0xFF3D7AB0)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text('Valor Total del Inventario', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text(
                            '\$${(_report['totalValue'] ?? 0.0).toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem('Productos', '${_report['totalProducts'] ?? 0}'),
                              _buildStatItem('Unidades', '${_report['totalUnits'] ?? 0}'),
                              _buildStatItem('Stock Bajo', '${_report['lowStockCount'] ?? 0}', color: Colors.red),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Lista de productos
                    Expanded(
                      child: (_report['items'] as List?)?.isEmpty ?? true
                          ? const Center(child: Text('No hay productos'))
                          : ListView.builder(
                              itemCount: (_report['items'] as List).length,
                              itemBuilder: (context, index) {
                                final item = _report['items'][index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: item['isLowStock'] ? Colors.red : Colors.green,
                                      child: const Icon(Icons.inventory_2, color: Colors.white, size: 20),
                                    ),
                                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('Código: ${item['code']}'),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('${item['stock']} und', style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: item['isLowStock'] ? Colors.red : Colors.green,
                                        )),
                                        Text('\$${item['value'].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color ?? Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
      ],
    );
  }

  Future<void> _exportCSV() async {
    final path = await _repository.exportInventoryToCSV();
    if (path.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Exportado a: $path'), duration: const Duration(seconds: 4)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error al exportar'), backgroundColor: Colors.red),
      );
    }
  }
}
