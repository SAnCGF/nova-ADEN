import 'package:flutter/material.dart';
import '../../core/models/product.dart';
import '../../core/models/supplier.dart';
import '../../core/repositories/product_repository.dart';
import '../../core/repositories/supplier_repository.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final ProductRepository _productRepo = ProductRepository();
  final SupplierRepository _supplierRepo = SupplierRepository();
  
  List<Product> _products = [];
  List<Supplier> _suppliers = [];
  Supplier? _selectedSupplier;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  
  // Líneas de compra simplificadas
  final Map<int, _PurchaseLine> _lines = {};

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
      if (_lines.containsKey(product.id)) {
        _lines[product.id]!.qty++;
      } else {
        _lines[product.id!] = _PurchaseLine(
          productId: product.id!,
          productName: product.nombre,
          qty: 1,
          cost: product.precioVenta * 0.7, // Costo estimado
        );
      }
    });
  }

  void _increaseQty(int productId) {
    setState(() => _lines[productId]!.qty++);
  }

  void _decreaseQty(int productId) {
    setState(() {
      _lines[productId]!.qty--;
      if (_lines[productId]!.qty <= 0) {
        _lines.remove(productId);
      }
    });
  }

  void _removeLine(int productId) {
    setState(() => _lines.remove(productId));
  }

  double get _total => _lines.values.fold(0.0, (sum, line) => sum + (line.cost * line.qty));

  Future<void> _confirmPurchase() async {
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Agrega productos'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Selecciona proveedor'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      // Actualizar stock de productos
      for (final line in _lines.values) {
        final product = _products.firstWhere((p) => p.id == line.productId);
        // Aquí se actualizaría el stock - simplificado por ahora
        await _productRepo.updateProduct(
          product.id!,
          Product(
            nombre: product.nombre,
            codigo: product.codigo,
            costo: line.cost,
            precio: product.precioVenta,
            stock: product.stockActual + line.qty,
            stockMinimo: product.stockMinimo,
          ),
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Compra: \$${_total.toStringAsFixed(2)}'), backgroundColor: Colors.green),
        );
      }
      setState(() => _lines.clear());
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSupplierDialog() {
    final nombreController = TextEditingController();
    final telefonoController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Proveedor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nombreController.text.isNotEmpty) {
                try {
                  await _supplierRepo.createSupplier(
                    Supplier(
                      nombre: nombreController.text.trim(),
                      telefono: telefonoController.text.trim(),
                    ),
                  );
                  await _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Proveedor registrado'), backgroundColor: Colors.green),
                    );
                    Navigator.pop(ctx);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compras'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Selector de Proveedor
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Proveedor:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<Supplier>(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: _suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.nombre))).toList(),
                              value: _selectedSupplier,
                              onChanged: (v) => setState(() => _selectedSupplier = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _showSupplierDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                // Buscador
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar producto...',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 12),
                // Lista de productos
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _products.where((p) => p.nombre.toLowerCase().contains(_searchController.text.toLowerCase())).length,
                    itemBuilder: (ctx, i) {
                      final p = _products.where((prod) => prod.nombre.toLowerCase().contains(_searchController.text.toLowerCase())).toList()[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.inventory_2, color: Colors.white),
                          ),
                          title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Stock: ${p.stockActual}'),
                              Text('Precio: \$${p.precioVenta.toStringAsFixed(2)}'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _addToPurchase(p),
                            child: const Text('Agregar'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Líneas de compra
                if (_lines.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, -2))],
                    ),
                    child: Column(
                      children: [
                        const Text('Productos a Comprar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 150),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _lines.length,
                            itemBuilder: (ctx, i) {
                              final line = _lines.values.elementAt(i);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 4),
                                child: ListTile(
                                  title: Text(line.productName),
                                  subtitle: Text('\$${line.cost.toStringAsFixed(2)} c/u'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 20),
                                        onPressed: () => _decreaseQty(line.productId),
                                      ),
                                      Text('${line.qty}'),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 20),
                                        onPressed: () => _increaseQty(line.productId),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                        onPressed: () => _removeLine(line.productId),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                              '\$${_total.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _confirmPurchase,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('CONFIRMAR COMPRA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _PurchaseLine {
  final int productId;
  final String productName;
  int qty;
  final double cost;

  _PurchaseLine({
    required this.productId,
    required this.productName,
    required this.qty,
    required this.cost,
  });
}
