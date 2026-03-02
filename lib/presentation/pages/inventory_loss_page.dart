import 'package:flutter/material.dart';
import '../../core/repositories/inventory_repository.dart';
import '../../core/repositories/product_repository.dart';

class InventoryLossPage extends StatefulWidget {
  const InventoryLossPage({super.key});

  @override
  State<InventoryLossPage> createState() => _InventoryLossPageState();
}

class _InventoryLossPageState extends State<InventoryLossPage> {
  final _inventoryRepo = InventoryRepository();
  final _productRepo = ProductRepository();
  List<Map<String, dynamic>> _products = [];
  List<Map<String, String>> _reasons = [];
  bool _isLoading = false;
  String? _selectedReason;
  int? _selectedProductId;
  double _quantity = 1;
  String _notes = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
  List<Map<String, dynamic>> _products = [];
      await _inventoryRepo.initializeReasons();
      _reasons = _inventoryRepo.getLossReasons();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _registerLoss() async {
    if (_selectedProductId == null || _selectedReason == null) return;
    
    setState(() => _isLoading = true);
    try {
      final product = _products.firstWhere((p) => p['id'] == _selectedProductId);
      final reason = _reasons.firstWhere((r) => r['name'] == _selectedReason);
      
      final success = await _inventoryRepo.registerLoss(
        productId: product['id'],
        quantity: _quantity.toInt(),
        reasonId: reason['id']!,
        reasonName: reason['name']!,
        notes: _notes,
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Pérdida registrada')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Pérdida de Inventario')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Selector de producto
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Producto'),
                    value: _selectedProductId,
                    items: _products.map((p) {
                      return DropdownMenuItem(
                        value: p['id'] as int,
                        child: Text('${p['nombre']} (Stock: ${p['stock']})'),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedProductId = v),
                  ),
                  const SizedBox(height: 16),
                  
                  // Selector de razón
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Razón'),
                    value: _selectedReason,
                    items: _reasons.map((r) {
                      return DropdownMenuItem(
                        value: r['name'],
                        child: Text(r['name']!),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedReason = v),
                  ),
                  const SizedBox(height: 16),
                  
                  // Cantidad
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _quantity = double.tryParse(v) ?? 1,
                  ),
                  const SizedBox(height: 16),
                  
                  // Notas
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Notas'),
                    maxLines: 3,
                    onChanged: (v) => _notes = v,
                  ),
                  const SizedBox(height: 24),
                  
                  // Botón registrar
                  ElevatedButton(
                    onPressed: _selectedProductId != null && _selectedReason != null ? _registerLoss : null,
                    child: const Text('Registrar Pérdida'),
                  ),
                ],
              ),
            ),
    );
  }
}
