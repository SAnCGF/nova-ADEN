import 'package:flutter/material.dart';
import 'package:nova_aden/core/repositories/product_repository.dart';
import 'package:nova_aden/core/repositories/sale_repository.dart';
import 'package:nova_aden/core/models/product.dart';

class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  final ProductRepository _productRepo = ProductRepository();
  final SaleRepository _saleRepo = SaleRepository();
  
  List<Product> _products = [];
  List<CartItem> _cart = [];
  bool _isLoading = true;
  String _searchQuery = '';
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    _products = await _productRepo.getAllProducts();
    setState(() => _isLoading = false);
  }

  void _addToCart(Product product) {
    setState(() {
      final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
      if (existingIndex >= 0) {
        _cart[existingIndex].quantity++;
      } else {
        _cart.add(CartItem(product: product, quantity: 1));
      }
      _calculateTotal();
    });
  }

  void _removeFromCart(int productId) {
    setState(() {
      _cart.removeWhere((item) => item.product.id == productId);
      _calculateTotal();
    });
  }

  void _updateQuantity(int productId, int quantity) {
    setState(() {
      final index = _cart.indexWhere((item) => item.product.id == productId);
      if (index >= 0) {
        if (quantity <= 0) {
          _cart.removeAt(index);
        } else {
          _cart[index].quantity = quantity;
        }
      }
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    _total = _cart.fold(0.0, (sum, item) => sum + (item.product.precioVenta * item.quantity));
  }

  Future<void> _completeSale() async {
    if (_cart.isEmpty) {
      _showSnackBar('⚠️ El carrito está vacío', Colors.orange);
      return;
    }

    if (_total <= 0) {
      _showSnackBar('⚠️ El total debe ser mayor a 0', Colors.orange);
      return;
    }

    // Confirmación
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    // Procesar venta
    setState(() => _isLoading = true);

    try {
      // Datos de la venta
      final saleData = {
        'numero_venta': DateTime.now().millisecondsSinceEpoch.toString(),
        'fecha': DateTime.now().toIso8601String(),
        'total': _total,
        'estado': 'completed',
        'cliente': 'Cliente General',
      };

      // Items de la venta
      final items = _cart.map((item) => {
        'producto_id': item.product.id,
        'nombre_producto': item.product.nombre,
        'cantidad': item.quantity,
        'precio_unitario': item.product.precioVenta,
        'subtotal': item.product.precioVenta * item.quantity,
        'descuento': 0.0,
        'total': item.product.precioVenta * item.quantity,
      }).toList();

      // Registrar venta
      final saleId = await _saleRepo.registerSale(saleData, items, true);

      if (saleId > 0 && mounted) {
        _showSnackBar('✅ Venta registrada exitosamente', Colors.green);
        _cart.clear();
        _calculateTotal();
        _loadProducts(); // Recargar productos (actualiza stock)
      } else {
        _showSnackBar('❌ Error al registrar la venta', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('❌ Error: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Venta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Productos: ${_cart.length}'),
            Text('Total: \$${_total.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('⚠️ Esta acción descontará el stock de los productos.', 
              style: TextStyle(fontSize: 12, color: Colors.orange)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A5F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
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
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Lista de productos (70%)
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      // Barra de búsqueda
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar producto...',
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
                      // Grid de productos
                      Expanded(
                        child: _filteredProducts.isEmpty
                            ? const Center(child: Text('No hay productos disponibles'))
                            : GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 0.85,
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
                ),
                // Carrito (30%)
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        left: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header del carrito
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: const Color(0xFF1E3A5F),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Carrito', 
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('${_cart.length} items',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        // Lista de items
                        Expanded(
                          child: _cart.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Carrito vacío',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _cart.length,
                                  itemBuilder: (ctx, index) {
                                    final item = _cart[index];
                                    return _buildCartItem(item);
                                  },
                                ),
                        ),
                        // Total y botón de pagar
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total:', 
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text('\$${_total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A5F),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: _cart.isEmpty ? null : _completeSale,
                                  icon: const Icon(Icons.payment, size: 24),
                                  label: const Text(
                                    'COMPLETAR VENTA',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A5F),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey[300],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProductCard(Product product) {
    final hasStock = product.stockActual > 0;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: hasStock ? () => _addToCart(product) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: hasStock
                ? null
                : LinearGradient(
                    colors: [Colors.grey[200]!, Colors.grey[300]!],
                  ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2,
                size: 48,
                color: hasStock ? const Color(0xFF1E3A5F) : Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                product.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '\$${product.precioVenta.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF1E3A5F),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: hasStock ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  hasStock ? 'Stock: ${product.stockActual}' : 'Sin stock',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasStock ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.product.precioVenta.toStringAsFixed(2)} c/u',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: () => _updateQuantity(item.product.id!, item.quantity - 1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: () => _updateQuantity(item.product.id!, item.quantity + 1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _removeFromCart(item.product.id!),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}
