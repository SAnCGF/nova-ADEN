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
  final TextEditingController _searchController = TextEditingController();

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

  void _addToPurchase(Product product) {
    setState(() {
      final existing = _lines.indexWhere((l) => l.productoId == product.id);
      if (existing >= 0) {
        _lines[existing].cantidad++;
      } else {
        _lines.add(PurchaseLine(productoId: product.id!, cantidad: 1, costoUnitario: product.costoPromedio));
      }
    });
  }

  void _increaseQty(int index) {
    setState(() => _lines[index].cantidad++);
  }

  void _decreaseQty(int index) {
    setState(() {
      _lines[index].cantidad--;
      if (_lines[index].cantidad <= 0) _lines.removeAt(index);
    });
  }

  void _removeLine(int index) {
    setState(() => _lines.removeAt(index));
  }

  double get _total => _lines.fold(0.0, (sum, l) => sum + (l.costoUnitario * l.cantidad));

  Future<void> _confirmPurchase() async {
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Agrega productos'), backgroundColor: Colors.orange));
      return;
    }
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Selecciona proveedor'), backgroundColor: Colors.orange));
      return;
    }

    try {
      await _purchaseRepo.createPurchase(_selectedSupplier!.id!, _lines);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Compra: \$${_total.toStringAsFixed(2)}'), backgroundColor: Colors.green));
      }
      setState(() => _lines.clear());
      _loadData();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
    }
  }

  void _showSupplierDialog() {
    final nc = TextEditingController(), cc = TextEditingController(), tc = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Nuevo Proveedor'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nc, decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: cc, decoration: const InputDecoration(labelText: 'Contacto', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: tc, decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder())),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () async {
          if (nc.text.isNotEmpty) {
            try {
              await _supplierRepo.createSupplier(Supplier(nombre: nc.text.trim(), contacto: cc.text.trim(), telefono: tc.text.trim()));
              await _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Proveedor registrado'), backgroundColor: Colors.green));
                Navigator.pop(ctx);
              }
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
            }
          }
        }, child: const Text('Guardar')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compras'), centerTitle: true),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(children: [
        // Selector de Proveedor
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Proveedor:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<Supplier>(
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              items: _suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.nombre))).toList(),
              value: _selectedSupplier,
              onChanged: (v) => setState(() => _selectedSupplier = v),
            ),
          ])),
          const SizedBox(width: 12),
          ElevatedButton.icon(onPressed: _showSupplierDialog, icon: const Icon(Icons.add), label: const Text('Nuevo'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16))),
        ])),
        // Buscador
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: TextField(
          controller: _searchController,
          decoration: InputDecoration(hintText: 'Buscar producto...', prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))), filled: true, fillColor: Colors.grey[100]),
          onChanged: (v) => setState(() {}),
        )),
        const SizedBox(height: 12),
        // Lista de productos
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _products.where((p) => p.nombre.toLowerCase().contains(_searchController.text.toLowerCase())).length,
          itemBuilder: (ctx, i) {
            final p = _products.where((prod) => prod.nombre.toLowerCase().contains(_searchController.text.toLowerCase())).toList()[i];
            return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.inventory_2, color: Colors.white)),
              title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Stock: ${p.stockActual}'), Text('Costo: \$${p.costoPromedio.toStringAsFixed(2)}')]),
              trailing: ElevatedButton(onPressed: () => _addToPurchase(p), child: const Text('Agregar')),
            ));
          },
        )),
        // Líneas de compra
        if (_lines.isNotEmpty) Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey[200], boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, -2))]),
          child: Column(children: [
            const Text('Líneas de Compra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ConstrainedBox(constraints: BoxConstraints(maxHeight: 150), child: ListView.builder(
              shrinkWrap: true,
              itemCount: _lines.length,
              itemBuilder: (ctx, i) => Card(margin: const EdgeInsets.only(bottom: 4), child: ListTile(
                title: Text(_products.firstWhere((p) => p.id == _lines[i].productoId).nombre),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(icon: const Icon(Icons.remove, size: 20), onPressed: () => _decreaseQty(i)),
                  Text('${_lines[i].cantidad}'),
                  IconButton(icon: const Icon(Icons.add, size: 20), onPressed: () => _increaseQty(i)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _removeLine(i)),
                ]),
              )),
            )),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('\$${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ElevatedButton.icon(onPressed: _confirmPurchase, icon: const Icon(Icons.check_circle), label: const Text('CONFIRMAR COMPRA'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)))),
            ]),
          ]),
        ),
      ]),
    );
  }
}
