import 'package:flutter/material.dart';
import 'package:nova_aden/core/repositories/report_repository.dart';
import 'package:intl/intl.dart';

class PurchasesReportPage extends StatefulWidget {
  const PurchasesReportPage({super.key});

  @override
  State<PurchasesReportPage> createState() => _PurchasesReportPageState();
}

class _PurchasesReportPageState extends State<PurchasesReportPage> {
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
    _report = await _repository.getPurchasesBySupplierReport(startDate: _startDate, endDate: _endDate);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compras por Proveedor')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _report.length,
              itemBuilder: (ctx, index) {
                final row = _report[index];
                return ListTile(
                  title: Text(row['proveedor_nombre']?.toString() ?? 'N/A'),
                  trailing: Text(
                    '\$${((row['total'] as num?) ?? 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
    );
  }
}
