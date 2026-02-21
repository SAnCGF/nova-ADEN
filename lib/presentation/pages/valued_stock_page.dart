import 'package:flutter/material.dart';
import 'package:nova_aden/core/repositories/inventory_repository.dart';
import 'package:intl/intl.dart';

class ValuedStockPage extends StatefulWidget {
  const ValuedStockPage({super.key});

  @override
  State<ValuedStockPage> createState() => _ValuedStockPageState();
}

class _ValuedStockPageState extends State<ValuedStockPage> {
  final InventoryRepository _repository = InventoryRepository();
  Map<String, dynamic> _summary = {};
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadValuedStock();
  }

  Future<void> _loadValuedStock() async {
    setState(() => _isLoading = true);
    _summary = await _repository.getValuedStock();
    _products = await _repository.getValuedStockByProduct();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Valorado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadValuedStock,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Resumen
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A5F), Color(0xFF3D7AB0)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('Valor Total del Inventario', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(
                        '\$${(_summary['totalValue'] ?? 0.0).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem('Productos', '${_summary['productCount'] ?? 0}'),
                          _buildStatItem('Unidades', '${_summary['totalUnits'] ?? 0}'),
                          _buildStatItem('Costo Prom.', '\$${(_summary['avgCost'] ?? 0.0).toStringAsFixed(2)}'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Lista de productos
                Expanded(
                  child: _products.isEmpty
                      ? const Center(child: Text('No hay productos en inventario'))
                      : ListView.builder(
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: (product['value'] ?? 0) > 100 ? Colors.green : Colors.blue,
                                  child: const Icon(Icons.inventory_2, color: Colors.white, size: 20),
                                ),
                                title: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Código: ${product['code']}'),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${product['stock']} und', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text('\$${product['cost']} c/u'),
                                    Text(
                                      '\$${(product['value'] ?? 0.0).toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
                                    ),
                                  ],
                                ),
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
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
      ],
    );
  }
}
