import 'package:flutter/material.dart';
import 'package:nova_aden/core/repositories/product_repository.dart';
import 'package:nova_aden/core/models/product.dart';
import 'package:nova_aden/core/models/cart_item.dart';
import 'cart_page.dart';

class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  final ProductRepository _productRepo = ProductRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<CartItem> _cart = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  void _addToCart(Product product) {
    if (product.stockActual <= 0) {
      _showSnackBar('⚠️ Producto sin stock', Colors.orange);
      return;
    }

    setState(() {
      final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
      if (existingIndex >= 0) {
        if (_cart[existingIndex].quantity < product.stockActual) {
          _cart[existingIndex].quantity++;
          _showSnackBar('✅ ${product.nombre} agregado al carrito', Colors.green);
        } else {
          _showSnackBar('⚠️ Stock máximo alcanzado', Colors.orange);
        }
      } else {
        _cart.add(CartItem(product: product, quantity: 1));
        _showSnackBar('✅ ${product.nombre} agregado al carrito', Colors.green);
      }
    });
  }

  void _openCart() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CartPage(cart: _cart),
      ),
    );

    if (result == true) {
      setState(() {
        _cart.clear();
      });
      _loadProducts();
      _showSnackBar('✅ Venta completada exitosamente', Colors.green);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products.where((p) =>
      p.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      p.codigo.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Punto de Venta'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Actualizar productos',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar producto por nombre o código...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _products.isEmpty
                                    ? 'No hay productos registrados'
                                    : 'No se encontraron productos',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (ctx, index) {
                            final product = _filteredProducts[index];
                            return _buildProductCard(product);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _cart.isNotEmpty ? _openCart : null,
        backgroundColor: _cart.isNotEmpty ? const Color(0xFF1E3A5F) : Colors.grey,
        icon: Stack(
          children: [
            const Icon(Icons.shopping_cart, size: 28),
            if (_cart.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    '${_cart.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        label: _cart.isNotEmpty
            ? Text(
                'Ver Carrito (\$${_cart.fold(0.0, (sum, item) => sum + (item.product.precioVenta * item.quantity)).toStringAsFixed(2)})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : const Text('Carrito vacío'),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final hasStock = product.stockActual > 0;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: hasStock ? () => _addToCart(product) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: hasStock
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E3A5F), Color(0xFF2D5A87)],
                  )
                : LinearGradient(colors: [Colors.grey[300]!, Colors.grey[400]!]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.inventory_2, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  product.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${product.precioVenta.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: hasStock ? Colors.white.withOpacity(0.3) : Colors.red.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasStock ? 'Stock: ${product.stockActual}' : 'Sin stock',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
