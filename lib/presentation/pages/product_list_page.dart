import 'package:flutter/material.dart';
import 'package:nova_aden/core/models/product.dart';
import 'package:nova_aden/core/repositories/product_repository.dart';
import 'package:nova_aden/presentation/widgets/product_card.dart';
import 'package:nova_aden/presentation/pages/product_form_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductRepository _repository = ProductRepository();
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = true;
  bool _showOnlyLowStock = false;

  @override
  void initState() {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProducts();
  }
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
    
    if (_showOnlyLowStock) {
      _products = await _repository.getLowStockProducts();
    } else {
      final query = _searchController.text.trim();
      _products = await _repository.searchProducts(query);
    }
    
    setState(() => _isLoading = false);
  }

  void _onSearchChanged(String value) {
    if (!_showOnlyLowStock) {
      _loadProducts();
    }
  }

  void _toggleLowStockFilter() {
    setState(() {
      _showOnlyLowStock = !_showOnlyLowStock;
      if (_showOnlyLowStock) {
        _searchController.clear();
      }
    });
    _loadProducts();
  }

  void _navigateToForm({Product? product}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductFormPage(product: product),
      ),
    ).then((_) => _loadProducts());
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _repository.deleteProduct(product.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto eliminado')),
        );
        _loadProducts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            icon: Icon(
              _showOnlyLowStock ? Icons.filter_list_off : Icons.warning_amber,
              color: _showOnlyLowStock ? Colors.red : null,
            ),
            onPressed: _toggleLowStockFilter,
            tooltip: _showOnlyLowStock ? 'Mostrar todos' : 'Solo stock bajo',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o código...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadProducts();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          
          // Filtro activo indicator
          if (_showOnlyLowStock)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Mostrando solo productos con stock bajo',
                    style: TextStyle(fontSize: 13, color: Colors.red),
                  ),
                ],
              ),
            ),
          
          // Lista de productos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _showOnlyLowStock ? Icons.check_circle : Icons.inventory_2,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _showOnlyLowStock
                                  ? 'No hay productos con stock bajo 🎉'
                                  : 'No se encontraron productos',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        child: ListView.builder(
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return ProductCard(
                              product: product,
                              onTap: () => _navigateToForm(product: product),
                              onEdit: () => _navigateToForm(product: product),
                              onDelete: () => _deleteProduct(product),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
        tooltip: 'Nuevo Producto',
      ),
    );
  }
}
