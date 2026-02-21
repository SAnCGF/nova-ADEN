import 'package:flutter/material.dart';
import 'package:nova_aden/core/repositories/inventory_repository.dart';
import 'package:nova_aden/core/models/inventory_loss.dart';
import 'package:nova_aden/core/models/loss_reason.dart';
import 'package:intl/intl.dart';

class LossHistoryPage extends StatefulWidget {
  const LossHistoryPage({super.key});

  @override
  State<LossHistoryPage> createState() => _LossHistoryPageState();
}

class _LossHistoryPageState extends State<LossHistoryPage> {
  final InventoryRepository _repository = InventoryRepository();
  List<InventoryLoss> _losses = [];
  List<LossReason> _reasons = [];
  String? _selectedReason;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _repository.initializeReasons();
    _reasons = await _repository.getLossReasons();
    _losses = await _repository.getLosses(startDate: _startDate, endDate: _endDate, reasonId: _selectedReason);
    setState(() => _isLoading = false);
  }

  double get _totalValue => _losses.fold<double>(0, (sum, l) => sum + l.totalValue);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Mermas'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilters, tooltip: 'Filtros'),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.red, Colors.orange]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text('Valor Total de Mermas', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text('\$${_totalValue.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${_losses.length} registros', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _losses.isEmpty
                    ? const Center(child: Text('No hay mermas registradas'))
                    : ListView.builder(
                        itemCount: _losses.length,
                        itemBuilder: (context, index) {
                          final loss = _losses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.warning_amber, color: Colors.white, size: 20)),
                              title: Text(loss.productName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DateFormat('dd/MM/yyyy').format(loss.date)),
                                  Text('Motivo: ${loss.reasonName}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${loss.quantity} und', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text('-\$${loss.totalValue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
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

  void _showFilters() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filtros'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Motivo:'),
            Wrap(
              children: [
                Chip(
                  label: const Text('Todos'),
                  backgroundColor: _selectedReason == null ? Colors.blue : Colors.grey,
                  labelStyle: TextStyle(color: _selectedReason == null ? Colors.white : Colors.black),
                  onPressed: () {
                    setState(() => _selectedReason = null);
                    Navigator.pop(ctx);
                    _loadData();
                  },
                ),
                ..._reasons.map((r) => Chip(
                  label: Text(r.name),
                  backgroundColor: _selectedReason == r.id ? Colors.blue : Colors.grey,
                  labelStyle: TextStyle(color: _selectedReason == r.id ? Colors.white : Colors.black),
                  onPressed: () {
                    setState(() => _selectedReason = r.id);
                    Navigator.pop(ctx);
                    _loadData();
                  },
                )),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }
}
