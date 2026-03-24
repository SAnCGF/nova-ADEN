import 'package:flutter/material.dart';
import '../../core/models/product.dart';
import '../../core/models/customer.dart';
import '../../core/models/sale.dart';
import '../../core/repositories/product_repository.dart';
import '../../core/repositories/customer_repository.dart';
import '../../core/repositories/sale_repository.dart';

class PosPage extends StatefulWidget {
  const PosPage({super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  final ProductRepository _productRepo = ProductRepository();
  final CustomerRepository _customerRepo = CustomerRepository();
  final SaleRepository _saleRepo = SaleRepository();
  
  List<CartItem> _cart = [];
  List<Product> _products = [];
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
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
    _customers = await _customerRepo.getAllCustomers();
    setState(() => _isLoading = false);
  }

  void _addToCart(Product product) {
    if (product.stockActual <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Sin stock disponible')),
      );
      return;
    }

    setState(() {
      final existing = _cart.indexWhere((c) => c.productoId == product.id);
      if (existing >= 0) {
        if (_cart[existing].cantidad < product.stockActual) {
          _cart[existing].cantidad++;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ No hay más stock disponible')),
          );
        }
      } else {
        _cart.add(CartItem(
          productoId: product.id!,
          nombre: product.nombre,
          precio: product.precioVenta,
          cantidad: 1,
          stockDisponible: product.stockActual,
        ));
      }
    });
  }

  void _updateQuantity(int index, int newQty) {
    if (newQty <= 0) {
      _cart.removeAt(index);
    } else if (newQty <= _cart[index].stockDisponible) {
      setState(() => _cart[index].cantidad = newQty);
    }
  }

  void _removeFromCart(int index) {
    setState(() => _cart.removeAt(index));
  }

  void _clearCart() {
    setState(() => _cart.clear());
  }

  Future<void> _completeSale() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Carrito vacío')),
      );
      return;
    }

    final lines = _cart.map((c) => SaleLine(
      ventaId: 0,
      productoId: c.productoId,
      cantidad: c.cantidad,
      precioUnitario: c.precio,
      subtotal: c.subtotal,
    )).toList();

    try {
      await _saleRepo.createSale(_selectedCustomer?.id, lines);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Venta realizada con éxito')),
      );
      _clearCart();
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  double get _total => _cart.fold(0.0, (sum, c) => sum + c.subtotal);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Punto de Venta'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(icon: const Icon(Icons.delete_sweep), onPressed: _clearCart),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(children: [
              // Lista de productos
              Expanded(
                flex: 2,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar producto...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setState(() {}),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _products
                          .where((p) => p.nombre
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase()))
                          .length,
                      itemBuilder: (ctx, i) {
                        final p = _products
                            .where((prod) => prod.nombre
                                .toLowerCase()
                                .contains(_searchController.text.toLowerCase()))
                            .toList()[i];
                        return ListTile(
                          leading: const Icon(Icons.inventory_2),
                          title: Text(p.nombre),
                          subtitle: Text('Stock: ${p.stockActual} | \$${p.precioVenta}'),
                          trailing: ElevatedButton(
                            onPressed: p.stockActual > 0 ? () => _addToCart(p) : null,
                            child: const Text('Agregar'),
                          ),
                        );
                      },
                    ),
                  ),
                ]),
              ),
              // Carrito
              Expanded(
                flex: 1,
                child: Column(children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Carrito', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  // Selector de cliente
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonFormField<Customer>(
                      decoration: const InputDecoration(labelText: 'Cliente (opcional)', border: OutlineInputBorder()),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Cliente General')),
                        ..._customers.map((c) => DropdownMenuItem(value: c, child: Text(c.nombre))),
                      ],
                      value: _selectedCustomer,
                      onChanged: (v) => setState(() => _selectedCustomer = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _cart.isEmpty
                        ? const Center(child: Text('Carrito vacío'))
                        : ListView.builder(
                            itemCount: _cart.length,
                            itemBuilder: (ctx, i) {
                              final c = _cart[i];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: ListTile(
                                  title: Text(c.nombre),
                                  subtitle: Text('\$${c.precio} x ${c.cantidad} = \$${c.subtotal.toStringAsFixed(2)}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () => _updateQuantity(i, c.cantidad - 1),
                                      ),
                                      Text('${c.cantidad}'),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () => _updateQuantity(i, c.cantidad + 1),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _removeFromCart(i),
                                      ),
                                    ],
                                  ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('\$${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _completeSale,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Confirmar Venta'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ]),
              ),
            ]),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
