import 'package:flutter/material.dart';
import 'package:nova_aden/core/repositories/report_repository.dart';
import 'package:intl/intl.dart';

class ProductMovementsReportPage extends StatefulWidget {
  const ProductMovementsReportPage({super.key});

  @override
  State<ProductMovementsReportPage> createState() => _ProductMovementsReportPageState();
}

class _ProductMovementsReportPageState extends State<ProductMovementsReportPage> {
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
    _report = await _repository.getProductMovementsReport(
      startDate: _startDate,
      endDate: _endDate,
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movimientos de Productos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => _startDate = date);
                              _loadReport();
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text('Inicio: ${DateFormat('dd/MM/yyyy').format(_startDate)}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate,
                              firstDate: _startDate,
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => _endDate = date);
                              _loadReport();
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text('Fin: ${DateFormat('dd/MM/yyyy').format(_endDate)}'),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _report.isEmpty
                      ? const Center(child: Text('No hay movimientos'))
                      : ListView.builder(
                          itemCount: _report.length,
                          itemBuilder: (ctx, index) {
                            final row = _report[index];
                            return ListTile(
                              title: Text(row['producto_nombre']?.toString() ?? 'N/A'),
                              subtitle: Text('Cantidad: ${(row['cantidad'] as num).toInt()}'),
                              trailing: Text(
                                '\$${(row['precio_unitario'] as num).toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
