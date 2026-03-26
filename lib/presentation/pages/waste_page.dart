import 'package:flutter/material.dart';
import '../../core/models/product.dart';
import '../../core/models/inventory_adjustment.dart';
import '../../core/repositories/product_repository.dart';
import '../../core/repositories/inventory_repository.dart';

class WastePage extends StatefulWidget {
  const WastePage({super.key});
  @override
  State<WastePage> createState() => _WastePageState();
}

class _WastePageState extends State<WastePage> {
  final _productRepo = ProductRepository();
  final _inventoryRepo = InventoryRepository();
  List<Product> _products = [];
  List<WasteRecord> _wastes = [];
  final Map<int, int> _quantities = {};
  WasteReason _selectedReason = WasteReason.damage;
  DateTime? _filterStart;
  DateTime? _filterEnd;
  bool _loading = false;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    _products = await _productRepo.getAllProducts();
    _wastes = await _inventoryRepo.getWastes(reason: _filterStart != null ? null : null, startDate: _filterStart, endDate: _filterEnd);
    setState(() => _loading = false);
  }

  void _addToWaste(Product p) {
    setState(() => _quantities[p.id!] = (_quantities[p.id!] ?? 0) + 1);
  }

  void _removeFromWaste(int productId) {
    setState(() {
      _quantities[productId] = (_quantities[productId] ?? 1) - 1;
      if (_quantities[productId]! <= 0) _quantities.remove(productId);
    });
  }

  Future<void> _registerBulkWaste() async {
    if (_quantities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Seleccione productos'), backgroundColor: Colors.orange));
      return;
    }
    setState(() => _loading = true);
    try {
      final wastes = _quantities.entries.map((e) => WasteRecord(
        productoId: e.key,
        productoNombre: _products.firstWhere((p) => p.id == e.key).nombre,
        cantidad: e.value,
        costoUnitario: _products.firstWhere((p) => p.id == e.key).costo ?? 0,
        reason: _selectedReason,
        fecha: DateTime.now().toIso8601String(),
      )).toList();
      await _inventoryRepo.registerBulkWaste(wastes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Mermas registradas'), backgroundColor: Colors.green));
        _quantities.clear();
        await _loadData();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text('Mermas'), centerTitle: true, bottom: const TabBar(tabs: [Tab(text: '📝 Registrar'), Tab(text: '📋 Historial')])),
        body: _loading ? const Center(child: CircularProgressIndicator()) : TabBarView(children: [
          // Pestaña Registrar
          SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🗑️ Motivo de Merma', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<WasteReason>(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              value: _selectedReason,
              items: WasteReason.values.map((r) => DropdownMenuItem(value: r, child: Text(r.toString().split('.').last.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _selectedReason = v!),
            ),
            const SizedBox(height: 16),
            const Text('📦 Productos a Merma', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._products.map((p) => Card(child: ListTile(
              title: Text(p.nombre),
              subtitle: Text('Stock actual: ${p.stockActual}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.remove), onPressed: _quantities[p.id!] != null ? () => _removeFromWaste(p.id!) : null),
                Text('${_quantities[p.id!] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add), onPressed: p.stockActual > 0 ? () => _addToWaste(p) : null),
              ]),
            ))),
            if (_quantities.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total a merma:'), Text('${_quantities.values.fold(0, (a, b) => a + b)} unidades')]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Pérdida estimada:'), Text('\$${_quantities.entries.fold(0.0, (s, e) => s + ((_products.firstWhere((p) => p.id == e.key).costo ?? 0) * e.value)).toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))]),
              ]))),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(
                onPressed: _registerBulkWaste,
                icon: const Icon(Icons.delete_forever),
                label: const Text('REGISTRAR MERMAS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              )),
            ],
          ])),
          // Pestaña Historial
          Column(children: [
            Padding(padding: const EdgeInsets.all(16), child: Row(children: [
              Expanded(child: ElevatedButton.icon(onPressed: () async { final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now()); if (d != null) setState(() => _filterStart = d); }, icon: const Icon(Icons.calendar_today), label: const Text('Desde'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(onPressed: () async { final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now()); if (d != null) setState(() => _filterEnd = d); }, icon: const Icon(Icons.calendar_today), label: const Text('Hasta'))),
              const SizedBox(width: 12),
              IconButton(icon: const Icon(Icons.filter_alt), onPressed: _loadData),
              IconButton(icon: const Icon(Icons.refresh), onPressed: () { setState(() { _filterStart = null; _filterEnd = null; }); _loadData(); }),
            ])),
            Expanded(child: _wastes.isEmpty ? const Center(child: Text('No hay mermas registradas')) : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _wastes.length,
              itemBuilder: (ctx, i) {
                final w = _wastes[i];
                return Card(child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.red, child: const Icon(Icons.warning, color: Colors.white)),
                  title: Text(w.productoNombre),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('🗑️ ${w.reason.toString().split('.').last.toUpperCase()}'),
                    Text('📅 ${w.fecha.split('T')[0]}'),
                    Text('💸 Pérdida: \$${w.totalLoss.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    if (w.notas != null) Text('📝 ${w.notas}'),
                  ]),
                  trailing: Text('x${w.cantidad}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ));
              },
            )),
          ]),
        ]),
      ),
    );
  }
}
