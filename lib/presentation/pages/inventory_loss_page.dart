import 'package:flutter/material.dart';
import 'package:nova_aden/core/models/product.dart';
import 'package:nova_aden/core/models/loss_reason.dart';
import 'package:nova_aden/core/repositories/product_repository.dart';
import 'package:nova_aden/core/repositories/inventory_repository.dart';
import 'package:intl/intl.dart';

class InventoryLossPage extends StatefulWidget {
  const InventoryLossPage({super.key});

  @override
  State<InventoryLossPage> createState() => _InventoryLossPageState();
}

class _InventoryLossPageState extends State<InventoryLossPage> {
  final ProductRepository _productRepo = ProductRepository();
  final InventoryRepository _inventoryRepo = InventoryRepository();
  
  List<Map<String, dynamic>> _cart = [];
  List<LossReason> _reasons = [];
  LossReason? _selectedReason;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isMassLoss = false;

  @override
  void initState() {
    super.initState();
    _loadReasons();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadReasons() async {
    await _inventoryRepo.initializeReasons();
    _reasons = await _inventoryRepo.getLossReasons();
    if (_reasons.isNotEmpty) {
      setState(() => _selectedReason = _reasons.first);
    }
  }

  Future<void> _addProductToLoss() async {
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
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('Stock: ${product.stock}'),
                onTap: () => Navigator.pop(ctx, product),
              );
            },
          ),
        ),
      ),
    );

    if (selected == null) return;

    final qtyController = TextEditingController(text: '1');
    
    final qty = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cantidad para ${selected.name}'),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Cantidad'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final q = int.tryParse(qtyController.text);
              if (q == null || q <= 0 || q > selected.stock) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Cantidad inválida o mayor al stock')),
                );
                return;
              }
              Navigator.pop(ctx, q);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );

    if (qty != null && qty > 0) {
      setState(() {
        _cart.add({
          'product': selected,
          'quantity': qty,
          'reasonId': _selectedReason?.id ?? 'OTRO',
          'reasonName': _selectedReason?.name ?? 'Otro',
        });
      });
    }
  }

  Future<void> _submitLosses() async {
    if (_cart.isEmpty) {
      _showSnackBar('Agrega productos a la merma', isError: true);
      return;
    }

    if (_selectedReason == null) {
      _showSnackBar('Selecciona un motivo', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Mermas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Productos: ${_cart.length}'),
            Text('Motivo: ${_selectedReason!.name}'),
            if (_notesController.text.isNotEmpty) Text('Notas: ${_notesController.text}'),
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

    bool success = true;
    for (final item in _cart) {
      final product = item['product'] as Product;
      final result = await _inventoryRepo.registerLoss(
        productId: product.id!,
        productName: product.name,
        productCode: product.code,
        quantity: item['quantity'],
        reasonId: item['reasonId'],
        reasonName: item['reasonName'],
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      if (!result) {
        success = false;
        break;
      }
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      _showSnackBar('✅ Mermas registradas exitosamente');
      setState(() {
        _cart.clear();
        _notesController.clear();
      });
    } else {
      _showSnackBar('Error al registrar mermas', isError: true);
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
        title: const Text('Registrar Mermas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _cart.clear()),
            tooltip: 'Nueva Merma',
          ),
        ],
      ),
      body: Column(
        children: [
          // Motivo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Motivo de Merma (RF 27)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<LossReason>(
                      value: _selectedReason,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.reason),
                      ),
                      items: _reasons.map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(),
                      onChanged: (v) => setState(() {
                        _selectedReason = v;
                        for (int i = 0; i < _cart.length; i++) {
                          _cart[i]['reasonId'] = v?.id ?? 'OTRO';
                          _cart[i]['reasonName'] = v?.name ?? 'Otro';
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Lista de productos
          Expanded(
            child: _cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('No hay productos agregados'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _addProductToLoss,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar Producto'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      final product = item['product'] as Product;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Text('Stock: ${product.stock} | Cantidad: ${item['quantity']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('\$${(product.cost * item['quantity']).toStringAsFixed(2)}'),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => setState(() => _cart.removeAt(index)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Botón agregar y confirmar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas (Opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _addProductToLoss,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar Producto'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitLosses,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('CONFIRMAR MERMAS'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
