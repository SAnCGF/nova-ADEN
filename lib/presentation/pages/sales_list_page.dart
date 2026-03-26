import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/sale.dart';
import '../../core/repositories/sale_repository.dart';

class SalesListPage extends StatefulWidget {
  const SalesListPage({super.key});
  @override
  State<SalesListPage> createState() => _SalesListPageState();
}

class _SalesListPageState extends State<SalesListPage> {
  final _repo = SaleRepository();
  List<Sale> _sales = [];
  bool _loading = true;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() { super.initState(); _loadSales(); }

  Future<void> _loadSales() async {
    setState(() => _loading = true);
    try {
      if (_startDate != null && _endDate != null) {
        _sales = await _repo.getSalesByDateRange(_startDate!, _endDate!);
      } else {
        _sales = await _repo.getTodaySales();
      }
    } catch (e) { print('Error: $e'); }
    setState(() => _loading = false);
  }

  Future<void> _showDateFilter() async {
    final start = await showDatePicker(context: context, initialDate: _startDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
    if (start == null) return;
    final end = await showDatePicker(context: context, initialDate: _endDate ?? start, firstDate: start, lastDate: DateTime.now());
    if (end != null) {
      setState(() { _startDate = start; _endDate = end; });
      _loadSales();
    }
  }

  void _showSaleDetail(int saleId) async {
    setState(() => _loading = true);
    final detail = await _repo.getSaleDetail(saleId);
    setState(() => _loading = false);
    if (detail.isEmpty) return;
    
    final sale = detail['venta'] as Sale;
    final lines = detail['lineas'] as List;
    
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Venta #${sale.id}'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('📅 ${_formatDate(sale.fecha)}'),
          Text('💰 Total: \$${sale.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (sale.esFiado) ...[
            const SizedBox(height: 8),
            Text('💵 Pagado: \$${sale.montoPagado.toStringAsFixed(2)}'),
            Text('⚠️ Pendiente: \$${sale.montoPendiente.toStringAsFixed(2)}', style: const TextStyle(color: Colors.orange)),
            if (sale.notasCredito != null) Text('📋 ${sale.notasCredito}'),
          ],
          const Divider(),
          const Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...lines.map((l) => ListTile(
            title: Text(l['producto_nombre'] ?? 'Producto'),
            subtitle: Text('\$${(l['precio_unitario'] as num).toStringAsFixed(2)} x ${l['cantidad']}'),
            trailing: Text('\$${(l['subtotal'] as num).toStringAsFixed(2)}'),
          )),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ElevatedButton.icon(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🧾 Ticket generado'))); }, icon: const Icon(Icons.print), label: const Text('Reimprimir')),
      ],
    ));
  }

  String _formatDate(String iso) {
    try { return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(iso)); } catch (_) { return iso; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ventas'), centerTitle: true, actions: [
        IconButton(icon: const Icon(Icons.filter_alt), onPressed: _showDateFilter),
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSales),
      ]),
      body: Column(children: [
        if (_startDate != null && _endDate != null)
          Container(padding: const EdgeInsets.all(12), color: Colors.blue[50], child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('📅 ${_formatDate(_startDate!.toIso8601String())} - ${_formatDate(_endDate!.toIso8601String())}'),
            TextButton(onPressed: () { setState(() { _startDate = null; _endDate = null; }); _loadSales(); }, child: const Text('Limpiar')),
          ])),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _sales.isEmpty ? const Center(child: Text('No hay ventas en el período')) : ListView.builder(
          padding: const EdgeInsets.all(16), itemCount: _sales.length,
          itemBuilder: (ctx, i) {
            final s = _sales[i];
            return Card(child: ListTile(
              leading: CircleAvatar(backgroundColor: s.esFiado ? Colors.orange : Colors.green, child: Icon(s.esFiado ? Icons.credit_card : Icons.check_circle, color: Colors.white)),
              title: Text('Venta #${s.id}'),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('🕐 ${_formatDate(s.fecha)}'),
                Text('💰 \$${s.total.toStringAsFixed(2)}'),
                if (s.esFiado) Text('⚠️ Pendiente: \$${s.montoPendiente.toStringAsFixed(2)}', style: const TextStyle(color: Colors.orange)),
              ]),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showSaleDetail(s.id!),
            ));
          },
        )),
      ]),
    );
  }
}
