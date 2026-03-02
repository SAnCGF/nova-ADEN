import 'package:flutter/material.dart';
import 'package:nova_aden/core/models/product.dart';
import 'package:nova_aden/core/models/purchase_item.dart';
import 'package:nova_aden/core/models/supplier.dart';
import 'package:nova_aden/core/repositories/product_repository.dart';
import 'package:nova_aden/core/repositories/purchase_repository.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final ProductRepository _productRepo = ProductRepository();
  final PurchaseRepository _purchaseRepo = PurchaseRepository();
  final TextEditingController _searchController = TextEditingController();
  
  List<Product> _products = [];
  List<PurchaseItem> _cart = [];
  Supplier? _selectedSupplier;
  bool _isQuickPurchase = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    _products = await _productRepo.getAllProducts();
    setState(() => _isLoading = false);
  }

  Future<void> _selectSupplier() async {
    final suppliers = await _purchaseRepo.getAllSuppliers();
    
    if (suppliers.isEmpty) {
      _showSnackBar('No hay proveedores registrados. Registra uno primero.', isError: true);
      return;
    }

    final selected = await showDialog<Supplier>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seleccionar Proveedor'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return ListTile(
                title: Text(supplier['nombre']),
                subtitle: Text(supplier['telefono'] ?? ''),
                onTap: () => Navigator.pop(ctx, supplier),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedSupplier = selected;
        _isQuickPurchase = false;
      });
    }
  }

  void _addToCart(Product product) {
    // Mostrar diálogo para ingresar cantidad y costo
    final qtyController = TextEditingController(text: '1');
    final costController = TextEditingController(text: product.cost.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Agregar ${product.nombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cantidad', prefixIcon: Icon(Icons.inventory_2)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: costController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Costo Unitario', prefixText: '\$ ', prefixIcon: Icon(Icons.attach_money)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(qtyController.text) ?? 0;
              final cost = double.tryParse(costController.text) ?? 0;
              
              if (qty <= 0 || cost <= 0) {
                _showSnackBar('Cantidad y costo deben ser mayores a 0', isError: true);
                return;
              }

              Navigator.pop(ctx);
              
              setState(() {
                final existingIndex = _cart.indexWhere((item) => item.productId == product.id);
                if (existingIndex >= 0) {
                  final existing = _cart[existingIndex];
                  _cart[existingIndex] = existing.copyWith(
                    quantity: existing.quantity + qty,
                    subtotal: (existing.quantity + qty) * cost,
                  );
                } else {
                  _cart.add(PurchaseItem(
                    productId: product.id!,
                    productName: product.nombre,
                    quantity: qty,
                    unitCost: cost,
                    subtotal: qty * cost,
                  ));
                }
              });
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _updateCartItem(int index, int quantity, double cost) {
    if (quantity <= 0) {
      _removeFromCart(index);
      return;
    }
    setState(() {
      _cart[index] = _cart[index].copyWith(
        quantity: quantity,
        subtotal: quantity * cost,
      );
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  double get _total => _cart.fold<double>(0, (sum, item) => sum + item.subtotal);

  Future<void> _completePurchase() async {
    if (_cart.isEmpty) {
      _showSnackBar('El carrito está vacío', isError: true);
      return;
    }

    if (!_isQuickPurchase && _selectedSupplier == null) {
      _showSnackBar('Selecciona un proveedor', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Productos: ${_cart.length}'),
            Text('Total: \$${_total.toStringAsFixed(2)}'),
            if (!_isQuickPurchase) Text('Proveedor: ${_selectedSupplier?.name}'),
            const SizedBox(height: 16),
            const Text('⚠️ Esta acción actualizará el stock y el costo promedio de los productos.', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    final purchaseData = {'numero_compra': DateTime.now().millisecondsSinceEpoch.toString(), 'fecha': DateTime.now().toIso8601String(), 'proveedor': _selectedSupplier?.name, 'total': _total, 'estado': 1};
    final success = await _purchaseRepo.registerPurchase(purchaseData, _cart.map((item) => item.toMap()).toList());

    setState(() => _isLoading = false);

    if (success == true && mounted) {
      _showSnackBar('✅ Compra registrada exitosamente');
      setState(() {
        _cart.clear();
        _selectedSupplier = null;
        _isQuickPurchase = true;
      });
    } else {
      _showSnackBar('Error al registrar compra', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Compra'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            onPressed: _selectSupplier,
            tooltip: 'Seleccionar Proveedor',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _cart.clear();
                _selectedSupplier = null;
                _isQuickPurchase = true;
              });
            },
            tooltip: 'Nueva Compra',
          ),
        ],
      ),
      body: Row(
        children: [
          // Lista de productos (60%)
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar producto...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            if (_searchController.text.isNotEmpty &&
                                !product.nombre.toLowerCase().contains(_searchController.text.toLowerCase()) &&
                                !product.code.toLowerCase().contains(_searchController.text.toLowerCase())) {
                              return const SizedBox.shrink();
                            }
                            return ListTile(
                              leading: const Icon(Icons.inventory_2, color: Color(0xFF1E3A5F)),
                              title: Text(product.nombre),
                              subtitle: Text('Stock: ${product.stockActual} | Costo: \$${product.costoPromedio}'),
                              trailing: ElevatedButton(
                                onPressed: () => _addToCart(product),
                                child: const Icon(Icons.add),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          
          // Carrito (40%)
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(left: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text('Carrito de Compra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (!_isQuickPurchase && _selectedSupplier != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text('Proveedor: ${_selectedSupplier!.name}', style: const TextStyle(fontSize: 11, color: Colors.green)),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _cart.isEmpty
                      ? const Center(child: Text('Carrito vacío'))
                      : ListView.builder(
                          itemCount: _cart.length,
                          itemBuilder: (context, index) {
                            final item = _cart[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: ListTile(
                                title: Text(item.productName, style: const TextStyle(fontSize: 14)),
                                subtitle: Text('\$${item.unitCost} x ${item.quantity}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 20),
                                      onPressed: () => _updateCartItem(index, item.quantity - 1, item.unitCost),
                                    ),
                                    Text('${item.quantity}'),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 20),
                                      onPressed: () => _updateCartItem(index, item.quantity + 1, item.unitCost),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                      onPressed: () => _removeFromCart(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Totales
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('\$${_total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ]),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _completePurchase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A5F),
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('CONFIRMAR COMPRA', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
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
