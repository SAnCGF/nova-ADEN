import 'package:flutter/material.dart';
import 'package:nova_aden/core/repositories/sale_repository.dart';
import 'package:intl/intl.dart';

class SaleDetailPage extends StatefulWidget {
  final int saleId;
  const SaleDetailPage({super.key, required this.saleId});

  @override
  State<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {
  final SaleRepository _repository = SaleRepository();
  Map<String, dynamic>? _saleData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSaleDetail();
  }

  Future<void> _loadSaleDetail() async {
    setState(() => _isLoading = true);
    _saleData = await _repository.getSaleDetail(widget.saleId);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_saleData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Venta')),
        body: const Center(child: Text('Venta no encontrada')),
      );
    }

    final sale = _saleData!['sale'];
    final items = _saleData!['items'] as List;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Venta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Número: ${sale.saleNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: sale.status == 'completed' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            sale.status == 'completed' ? 'Completada' : 'Pendiente',
                            style: TextStyle(color: sale.status == 'completed' ? Colors.green : Colors.orange, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildInfoRow('Fecha', DateFormat('dd/MM/yyyy HH:mm').format(sale.date)),
                    if (sale.customerName != null) _buildInfoRow('Cliente', sale.customerName),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Productos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item['product_name']),
                    subtitle: Text('Código: ${item['product_code']}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${item['quantity']} x \$${item['unit_price'].toStringAsFixed(2)}'),
                        Text('\$${item['subtotal'].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTotalRow('Subtotal', sale.subtotal),
                    if (sale.discount > 0) _buildTotalRow('Descuento', -sale.discount, isNegative: true),
                    const Divider(),
                    _buildTotalRow('TOTAL', sale.total, isTotal: true),
                    const Divider(),
                    _buildTotalRow('Pagado', sale.paid),
                    _buildTotalRow('Cambio', sale.change),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, {bool isNegative = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text('${isNegative ? '-' : ''}\$${value.abs().toStringAsFixed(2)}', style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
