import 'package:flutter/material.dart';
import 'package:nova_aden/core/repositories/purchase_repository.dart';
import 'package:nova_aden/core/models/purchase.dart';
import 'package:intl/intl.dart';

class PurchaseListPage extends StatefulWidget {
  const PurchaseListPage({super.key});

  @override
  State<PurchaseListPage> createState() => _PurchaseListPageState();
}

class _PurchaseListPageState extends State<PurchaseListPage> {
  final PurchaseRepository _repository = PurchaseRepository();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  List<Purchase> _purchases = [];
  bool _isLoading = false;
  String _filterType = 'today';

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    setState(() => _isLoading = true);
    
    List<Purchase> purchases;
    if (_filterType == 'today') {
      purchases = await _repository.getTodayPurchases();
    } else {
      purchases = await _repository.getPurchasesByDateRange(_startDate, _endDate);
    }
    
    setState(() {
      _purchases = purchases;
      _isLoading = false;
    });
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
      _filterType = 'custom';
    });
    _loadPurchases();
  }

  double get _totalPurchases => _purchases.fold<double>(0, (sum, p) => sum + p.total);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Compras'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _filterType = value);
              _loadPurchases();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'today', child: Text('Hoy')),
              const PopupMenuItem(value: 'week', child: Text('Esta semana')),
              const PopupMenuItem(value: 'month', child: Text('Este mes')),
              const PopupMenuItem(value: 'custom', child: Text('Personalizado...')),
            ],
          ),
          if (_filterType == 'custom')
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _selectDateRange,
              tooltip: 'Seleccionar fechas',
            ),
        ],
      ),
      body: Column(
        children: [
          // Resumen
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF3D7AB0)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('Total del Período', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                const SizedBox(height: 8),
                Text('\$${_totalPurchases.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${_purchases.length} compras', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
              ],
            ),
          ),
          
          // Lista
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _purchases.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('No hay compras en este período', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPurchases,
                        child: ListView.builder(
                          itemCount: _purchases.length,
                          itemBuilder: (context, index) {
                            final purchase = _purchases[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: purchase.status == 'completed' ? Colors.green : Colors.orange,
                                  child: Icon(purchase.status == 'completed' ? Icons.check : Icons.pending, color: Colors.white, size: 20),
                                ),
                                title: Text(purchase.purchaseNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(DateFormat('dd/MM/yyyy HH:mm').format(purchase.date)),
                                    Text('Proveedor: ${purchase.supplierName ?? 'Compra Rápida'}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('\$${purchase.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
