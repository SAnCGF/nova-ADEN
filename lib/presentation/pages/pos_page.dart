import 'package:flutter/material.dart';
import 'package:nova_aden/core/models/product.dart';
import 'package:nova_aden/core/models/sale_item.dart';
import 'package:nova_aden/core/repositories/product_repository.dart';
import 'package:nova_aden/core/repositories/sale_repository.dart';

class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  final ProductRepository _productRepo = ProductRepository();
  final SaleRepository _saleRepo = SaleRepository();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _paidController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();

  List<Product> _products = [];
  List<SaleItem> _cart = [];
  bool _isLoading = false;
  double _discount = 0;
  bool _isPartialPayment = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    _paidController.dispose();
    _customerController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    _products = await _productRepo.getAllProducts();
    setState(() => _isLoading = false);
  }

  void _addToCart(Product product) {
    final existingIndex = _cart.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex >= 0) {
      // Actualizar cantidad
      final existingItem = _cart[existingIndex];
      if (existingItem.quantity < product.stock) {
        setState(() {
          _cart[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
        });
      } else {
        _showSnackBar('Stock máximo alcanzado', isError: true);
      }
    } else {
      // Agregar nuevo
      setState(() {
        _cart.add(SaleItem(
          productId: product.id!,
          productName: product.name,
          productCode: product.code,
          quantity: 1,
          unitPrice: product.price,
          subtotal: product.price,
        ));
      });
    }
  }

  void _updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      _removeFromCart(index);
      return;
    }
    final product = _products.firstWhere((p) => p.id == _cart[index].productId);
    if (quantity > product.stock) {
      _showSnackBar('Stock disponible: ${product.stock}', isError: true);
      return;
    }
    setState(() {
      _cart[index] = _cart[index].copyWith(
        quantity: quantity,
        subtotal: quantity * _cart[index].unitPrice,
      );
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  double get _subtotal => _cart.fold<double>(0, (sum, item) => sum + item.subtotal);
  double get _total => _subtotal - _discount;
  double get _change => (_paidController.text.isNotEmpty ? double.tryParse(_paidController.text) ?? 0 : 0) - _total;

  Future<void> _completeSale() async {
    if (_cart.isEmpty) {
      _showSnackBar('El carrito está vacío', isError: true);
      return;
    }

    final paid = double.tryParse(_paidController.text) ?? 0;
    if (!_isPartialPayment && paid < _total) {
      _showSnackBar('El pago es insuficiente', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final success = await _saleRepo.registerSale(
      items: _cart,
      discount: _discount,
      paid: paid,
      customerName: _customerController.text.isEmpty ? null : _customerController.text,
      isPartialPayment: _isPartialPayment,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      _showSnackBar('✅ Venta registrada exitosamente');
      // Generar ticket (RF 19)
      _showTicket();
      // Limpiar carrito
      setState(() {
        _cart.clear();
        _discountController.clear();
        _paidController.clear();
        _customerController.clear();
        _discount = 0;
        _isPartialPayment = false;
      });
    } else {
      _showSnackBar('Error al registrar venta', isError: true);
    }
  }

  void _showTicket() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🧾 Ticket de Venta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('nova-ADEN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(),
              ..._cart.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.quantity}x ${item.productName}'),
                    Text('\$${item.subtotal.toStringAsFixed(2)}'),
                  ],
                ),
              )),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Subtotal:'),
                Text('\$${_subtotal.toStringAsFixed(2)}'),
              ]),
              if (_discount > 0)
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Descuento:'),
                  Text('-\$${_discount.toStringAsFixed(2)}'),
                ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('\$${_total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Pagado:'),
                Text('\$${(_paidController.text.isNotEmpty ? double.tryParse(_paidController.text) ?? 0 : 0).toStringAsFixed(2)}'),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Cambio:'),
                Text('\$${_change.toStringAsFixed(2)}'),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
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
        title: const Text('Venta Rápida'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _cart.clear());
              _loadProducts();
            },
            tooltip: 'Nueva Venta',
          ),
        ],
      ),
      body: Row(
        children: [
          // Lista de productos (60% ancho)
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
                    onChanged: (value) {
                      setState(() {});
                    },
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
                                !product.name.toLowerCase().contains(_searchController.text.toLowerCase()) &&
                                !product.code.toLowerCase().contains(_searchController.text.toLowerCase())) {
                              return const SizedBox.shrink();
                            }
                            return ListTile(
                              leading: const Icon(Icons.inventory_2, color: Color(0xFF1E3A5F)),
                              title: Text(product.name),
                              subtitle: Text('Stock: ${product.stock} | \$${product.price}'),
                              trailing: product.stock > 0
                                  ? ElevatedButton(
                                      onPressed: () => _addToCart(product),
                                      child: const Icon(Icons.add),
                                    )
                                  : const Text('Agotado', style: TextStyle(color: Colors.red)),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          
          // Carrito (40% ancho)
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(left: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Carrito', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                subtitle: Text('\$${item.unitPrice} x ${item.quantity}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 20),
                                      onPressed: () => _updateQuantity(index, item.quantity - 1),
                                    ),
                                    Text('${item.quantity}'),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 20),
                                      onPressed: () => _updateQuantity(index, item.quantity + 1),
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
                // Totales y pago
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Subtotal:'),
                        Text('\$${_subtotal.toStringAsFixed(2)}'),
                      ]),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Descuento:'),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: _discountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                            onChanged: (v) => setState(() => _discount = double.tryParse(v) ?? 0),
                          ),
                        ),
                      ]),
                      const Divider(),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('\$${_total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ]),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _paidController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Pago recibido',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Cambio:'),
                        Text('\$${_change.toStringAsFixed(2)}', style: TextStyle(color: _change >= 0 ? Colors.green : Colors.red)),
                      ]),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Pago parcial / Fiado'),
                        value: _isPartialPayment,
                        onChanged: (v) => setState(() => _isPartialPayment = v),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _completeSale,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A5F),
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('CONFIRMAR VENTA', style: TextStyle(fontSize: 16)),
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
