import 'package:flutter/material.dart';
import 'package:nova_aden/core/repositories/report_repository.dart';
import 'package:intl/intl.dart';

class ProfitReportPage extends StatefulWidget {
  const ProfitReportPage({super.key});

  @override
  State<ProfitReportPage> createState() => _ProfitReportPageState();
}

class _ProfitReportPageState extends State<ProfitReportPage> {
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
    _report = await _repository.getProfitReport(startDate: _startDate, endDate: _endDate);
    setState(() => _isLoading = false);
  }

  Future<void> _selectDateRange() async {
    final start = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (start == null) return;
    final end = await showDatePicker(context: context, initialDate: _endDate, firstDate: start, lastDate: DateTime.now());
    if (end == null) return;
    setState(() { _startDate = start; _endDate = end; });
    _loadReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Ganancias'),
        actions: [IconButton(icon: const Icon(Icons.calendar_today), onPressed: _selectDateRange)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _report.isEmpty
              ? const Center(child: Text('No hay datos'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSummaryCard(),
                      const SizedBox(height: 16),
                      _buildDetailCards(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard() {
    final profit = _report['grossProfit'] ?? 0.0;
    final margin = _report['profitMargin'] ?? 0.0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [profit >= 0 ? Colors.green : Colors.red, profit >= 0 ? Colors.teal : Colors.orange]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('Ganancia Neta', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            '\$${profit.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(
              'Margen: ${margin.toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCards() {
    return Column(
      children: [
        _buildDetailCard('Ingresos Totales', '\$${(_report['totalRevenue'] ?? 0.0).toStringAsFixed(2)}', Icons.attach_money, Colors.green),
        const SizedBox(height: 12),
        _buildDetailCard('Costo de Ventas', '\$${(_report['totalCost'] ?? 0.0).toStringAsFixed(2)}', Icons.payments, Colors.orange),
        const SizedBox(height: 12),
        _buildDetailCard('Transacciones', '${_report['transactions'] ?? 0}', Icons.receipt, Colors.blue),
      ],
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(label),
        trailing: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}
