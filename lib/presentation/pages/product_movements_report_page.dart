import 'package:flutter/material.dart';
import 'package:nova_aden/core/repositories/report_repository.dart';
import 'package:nova_aden/core/repositories/product_repository.dart';
import 'package:nova_aden/core/models/product.dart';
import 'package:intl/intl.dart';

class ProductMovementsReportPage extends StatefulWidget {
  const ProductMovementsReportPage({super.key});

  @override
  State<ProductMovementsReportPage> createState() => _ProductMovementsReportPageState();
}

class _ProductMovementsReportPageState extends State<ProductMovementsReportPage> {
  final ReportRepository _repository = ReportRepository();
  final ProductRepository _productRepo = ProductRepository();
  Product? _selectedProduct;
  Map<String, dynamic> _report = {};
  bool _isLoading = false;

  Future<void> _selectProduct() async {
    final products = await _productRepo.getAllProducts();
    final selected = await showDialog<Product>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seleccionar Producto'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: products.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(products[index].name),
              subtitle: Text('Stock: ${products[index].stock}'),
              onTap: () => Navigator.pop(ctx, products[index]),
            ),
          ),
        ),
      ),
    );
    if (selected != null) {
      setState(() => _selectedProduct = selected);
      _loadReport();
    }
  }

  Future<void> _loadReport() async {
    if (_selectedProduct == null) return;
    setState(() => _isLoading = true);
    _report = await _repository.getProductMovementsReport(productId: _selectedProduct!.id!);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos por Producto'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: _selectProduct)],
      ),
      body: _selectedProduct == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.swap_horiz, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Selecciona un producto para ver sus movimientos'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _selectProduct,
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar Producto'),
                  ),
                ],
              ),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF3D7AB0)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(_selectedProduct!.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem('Stock Actual', '${_selectedProduct!.stock}'),
                              _buildStatItem('Entradas', '${_report['totalEntries'] ?? 0}'),
                              _buildStatItem('Salidas', '${_report['totalExits'] ?? 0}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: (_report['movements'] as List?)?.isEmpty ?? true
                          ? const Center(child: Text('No hay movimientos registrados'))
                          : ListView.builder(
                              itemCount: (_report['movements'] as List).length,
                              itemBuilder: (context, index) {
                                final movement = _report['movements'][index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: movement['type'] == 'Entrada' ? Colors.green : Colors.red,
                                      child: Icon(movement['type'] == 'Entrada' ? Icons.add : Icons.remove, color: Colors.white),
                                    ),
                                    title: Text('${movement['type']}: ${movement['quantity']} und'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(DateFormat('dd/MM/yyyy HH:mm').format(movement['date'])),
                                        Text('Motivo: ${movement['reason']}'),
                                      ],
                                    ),
                                    trailing: Text(movement['reference']),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
    ]);
  }
}
