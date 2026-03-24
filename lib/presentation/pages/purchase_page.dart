import 'package:flutter/material.dart';
import '../../core/models/product.dart';
import '../../core/models/supplier.dart';
import '../../core/models/purchase.dart';
import '../../core/repositories/product_repository.dart';
import '../../core/repositories/supplier_repository.dart';
import '../../core/repositories/purchase_repository.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final ProductRepository _productRepo = ProductRepository();
  final SupplierRepository _supplierRepo = SupplierRepository();
  final PurchaseRepository _purchaseRepo = PurchaseRepository();
  
  List<Product> _products = [];
  List<Supplier> _suppliers = [];
  List<PurchaseLine> _lines = [];
  Supplier? _selectedSupplier;
  bool _isLoading = true;
  bool _hasSupplier = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _products = await _productRepo.getAllProducts();
    _suppliers = await _supplierRepo.getAllSuppliers();
    setState(() => _isLoading = false);
  }

  void _addLine(Product p) {
    final existing = _lines.indexWhere((l) => l.productoId == p.id);
    if (existing >= 0) {
      setState(() {
        final line = _lines[existing];
        _lines[existing] = PurchaseLine(
          id: line.id, compraId: line.compraId, productoId: line.productoId,
          cantidad: line.cantidad + 1, costoUnitario: line.costoUnitario,
          subtotal: (line.cantidad + 1) * line.costoUnitario,
        );
      });
    } else {
      setState(() {
        _lines.add(PurchaseLine(
          compraId: 0, productoId: p.id!, cantidad: 1,
          costoUnitario: p.costo, subtotal: p.costo,
        ));
      });
    }
  }

  void _updateLine(int idx, int qty, double cost) {
    if (qty <= 0) {
      _lines.removeAt(idx);
    } else {
      setState(() {
        _lines[idx] = PurchaseLine(
          id: _lines[idx].id, compraId: _lines[idx].compraId, productoId: _lines[idx].productoId,
          cantidad: qty, costoUnitario: cost, subtotal: qty * cost,
        );
      });
    }
  }

  void _removeLine(int idx) => setState(() => _lines.removeAt(idx));
  void _clearLines() => setState(() => _lines.clear());

  double get _total => _lines.fold(0.0, (sum, l) => sum + l.subtotal);

  Future<void> _confirmPurchase() async {
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Agrega productos')));
      return;
    }
    if (_hasSupplier && _selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Selecciona un proveedor')));
      return;
    }

    try {
      if (_hasSupplier) {
        await _purchaseRepo.createPurchaseWithSupplier(_selectedSupplier!.id!, _lines);
      } else {
        await _purchaseRepo.createQuickPurchase(_lines);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Compra confirmada')));
      _clearLines();
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compras'), centerTitle: true, actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        IconButton(icon: const Icon(Icons.delete_sweep), onPressed: _clearLines),
      ]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(children: [
              Expanded(
                flex: 2,
                child: Column(children: [
                  const Padding(padding: EdgeInsets.all(8), child: Text('Productos Disponibles', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (ctx, i) {
                        final p = _products[i];
                        return ListTile(
                          leading: const Icon(Icons.inventory_2),
                          title: Text(p.nombre),
                          subtitle: Text('Stock: ${p.stockActual} | Costo: \$${p.costo}'),
                          trailing: ElevatedButton(onPressed: () => _addLine(p), child: const Text('Agregar')),
                        );
                      },
                    ),
                  ),
                ]),
              ),
              Expanded(
                flex: 1,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(children: [
                      const Text('Proveedor:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Checkbox(value: _hasSupplier, onChanged: (v) => setState(() => _hasSupplier = v!)),
                      const Text('¿Con proveedor?'),
                    ]),
                  ),
                  if (_hasSupplier)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButtonFormField<Supplier>(
                        decoration: const InputDecoration(labelText: 'Seleccionar Proveedor', border: OutlineInputBorder()),
                        items: _suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.nombre))).toList(),
                        value: _selectedSupplier,
                        onChanged: (v) => setState(() => _selectedSupplier = v),
                      ),
                    ),
                  const Padding(padding: EdgeInsets.all(8), child: Text('Líneas de Compra', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                    child: _lines.isEmpty
                        ? const Center(child: Text('Sin productos'))
                        : ListView.builder(
                            itemCount: _lines.length,
                            itemBuilder: (ctx, i) {
                              final l = _lines[i];
                              final prod = _products.firstWhere((p) => p.id == l.productoId, orElse: () => _products[0]);
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: ListTile(
                                  title: Text(prod.nombre),
                                  subtitle: Text('\$${l.costoUnitario} x ${l.cantidad} = \$${l.subtotal.toStringAsFixed(2)}'),
                                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                    IconButton(icon: const Icon(Icons.remove), onPressed: () => _updateLine(i, l.cantidad - 1, l.costoUnitario)),
                                    Text('${l.cantidad}'),
                                    IconButton(icon: const Icon(Icons.add), onPressed: () => _updateLine(i, l.cantidad + 1, l.costoUnitario)),
                                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _removeLine(i)),
                                  ]),
                                ),
                              );
                            },
                          ),
                  ),
                  Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('\$${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                        ]),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _confirmPurchase,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Confirmar Compra'),
                          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: Colors.green),
                        ),
                      ]),
                    ),
                  ),
                ]),
              ),
            ]),
    );
  }
}
