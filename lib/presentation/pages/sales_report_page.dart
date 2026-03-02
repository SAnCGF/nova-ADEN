import 'package:flutter/material.dart';
import 'package:nova_aden/core/repositories/report_repository.dart';
import 'package:intl/intl.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  final ReportRepository _repository = ReportRepository();
  Map<String, dynamic> _report = {};
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    _report = await _repository.getSalesDetailReport(_startDate ?? DateTime.now(), _endDate ?? DateTime.now());
    setState(() => _isLoading = false);
  }

  Future<void> _selectDateRange() async {
    final start = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (start == null) return;
    
    final end = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: start,
      lastDate: DateTime.now(),
    );
    if (end == null) return;
    
    setState(() {
      _startDate = start;
      _endDate = end;
    });
    _loadReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
            tooltip: 'Seleccionar fechas',
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
              ? const Center(child: Text('No hay ventas en este período'))
              : Column(
                  children: [
                    // Filtro de fechas
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            '${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    
                    // Resumen
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Colors.green, Colors.teal]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text('Ventas Netas', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text(
                            '\$${(_report['netRevenue'] ?? 0.0).toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem('Transacciones', '${_report['totalTransactions'] ?? 0}'),
                              _buildStatItem('Descuentos', '\$${(_report['totalDiscount'] ?? 0.0).toStringAsFixed(2)}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Lista de ventas
                    Expanded(
                      child: (_report['items'] as List?)?.isEmpty ?? true
                          ? const Center(child: Text('No hay ventas'))
                          : ListView.builder(
                              itemCount: (_report['items'] as List).length,
                              itemBuilder: (context, index) {
                                final item = _report['items'][index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Colors.green,
                                      child: Icon(Icons.shopping_bag, color: Colors.white, size: 20),
                                    ),
                                    title: Text(item['productName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Venta: ${item['saleNumber']}'),
                                        Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(item['date'])}'),
                                        Text('Cliente: ${item['customer']}'),
                                      ],
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('${item['quantity']} x \$${item['unitPrice'].toStringAsFixed(2)}'),
                                        Text('\$${item['subtotal'].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
      ],
    );
  }

  Future<void> _exportCSV() async {
    final path = await _repository.exportSalesToCSV();
    if (path== true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Exportado a: $path'), duration: const Duration(seconds: 4)),
      );
    }
  }
}
