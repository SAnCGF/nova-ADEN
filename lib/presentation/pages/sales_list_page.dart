import 'package:flutter/material.dart';
import 'package:nova_aden/core/models/sale.dart';
import 'package:nova_aden/core/repositories/sale_repository.dart';
import 'package:nova_aden/presentation/pages/sale_detail_page.dart';
import 'package:intl/intl.dart';

class SalesListPage extends StatefulWidget {
  const SalesListPage({super.key});

  @override
  State<SalesListPage> createState() => _SalesListPageState();
}

class _SalesListPageState extends State<SalesListPage> {
  final SaleRepository _repository = SaleRepository();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  List<Sale> _sales = [];
  bool _isLoading = false;
  String _filterType = 'today'; // 'today', 'week', 'month', 'custom'

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() => _isLoading = true);
    
    List<Sale> sales;
    if (_filterType == 'today') {
      sales = await _repository.getTodaySales();
    } else if (_filterType == 'custom') {
      sales = await _repository.getSalesByDateRange(_startDate, _endDate);
    } else {
      // week or month
      final now = DateTime.now();
      if (_filterType == 'week') {
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate = now;
      } else {
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
      }
      sales = await _repository.getSalesByDateRange(_startDate, _endDate);
    }
    
    setState(() {
      _sales = sales;
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
    _loadSales();
  }

  double get _totalSales => _sales.fold<double>(0, (sum, sale) => sum + sale.total);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _filterType = value);
              _loadSales();
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
          // Resumen del período
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
                Text(
                  'Total del Período',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${_totalSales.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_sales.length} ventas',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
              ],
            ),
          ),
          
          // Filtro activo
          if (_filterType == 'custom')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
          
          // Lista de ventas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sales.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No hay ventas en este período',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadSales,
                        child: ListView.builder(
                          itemCount: _sales.length,
                          itemBuilder: (context, index) {
                            final sale = _sales[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: sale.status == 'completed' ? Colors.green : Colors.orange,
                                  child: Icon(
                                    sale.status == 'completed' ? Icons.check : Icons.pending,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  sale.saleNumber,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(DateFormat('dd/MM/yyyy HH:mm').format(sale.date)),
                                    if (sale.customerName != null)
                                      Text('Cliente: ${sale.customerName}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                    if (sale.isPartialPayment)
                                      const Text('⚠️ Pago parcial', style: TextStyle(fontSize: 12, color: Colors.orange)),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${sale.total.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    if (sale.isPartialPayment)
                                      Text(
                                        'Pagado: \$${sale.paid.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 12, color: Colors.orange),
                                      ),
                                  ],
                                ),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => SaleDetailPage(saleId: sale.id!)),
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
