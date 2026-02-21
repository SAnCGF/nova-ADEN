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
    _report = await _repository.getPurchasesBySupplierReport(startDate: _startDate, endDate: _endDate);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compras por Proveedor')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _report.isEmpty
              ? const Center(child: Text('No hay compras'))
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text('Total Comprado', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text(
                            '${_report['totalPurchases'] ?? 0} compras',
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('${_report['totalSuppliers'] ?? 0} proveedores', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: (_report['bySupplier'] as Map?)?.entries.map((entry) {
                          final supplier = entry.value;
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ExpansionTile(
                              leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.business, color: Colors.white)),
                              title: Text(supplier['supplierName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${supplier['purchaseCount']} compras'),
                              trailing: Text('\$${(supplier['totalAmount'] ?? 0.0).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              children: (supplier['purchases'] as List).map((p) => ListTile(
                                title: Text(p['number']),
                                subtitle: Text(DateFormat('dd/MM/yyyy').format(p['date'])),
                                trailing: Text('\$${(p['total'] ?? 0.0).toStringAsFixed(2)}'),
                              )).toList(),
                            ),
                          );
                        }).toList() ?? [],
                      ),
                    ),
                  ],
                ),
    );
  }
}
