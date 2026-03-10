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
  List<Map<String, dynamic>> _report = [];
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
    _report = await _repository.getSalesDetailReport(startDate: _startDate, endDate: _endDate);
    setState(() => _isLoading = false);
  }

  Future<void> _exportCSV() async {
    final csvData = await _repository.exportSalesToCSV(_report);
    if (csvData.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ CSV exportado exitosamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Ventas'),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: _exportCSV),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _report.length,
              itemBuilder: (ctx, index) {
                final item = _report[index];
                return ListTile(
                  title: Text(item['producto_nombre']?.toString() ?? 'N/A'),
                  subtitle: Text('Cantidad: ${(item['cantidad'] as num?)?.toInt() ?? 0}'),
                  trailing: Text(
                    '\$${((item['total'] as num?) ?? 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
    );
  }
}
