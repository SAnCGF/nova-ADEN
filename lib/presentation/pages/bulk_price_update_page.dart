import 'package:flutter/material.dart';
import 'package:nova_aden/core/models/product.dart';
import 'package:nova_aden/core/repositories/product_repository.dart';

class BulkPriceUpdatePage extends StatefulWidget {
  final List<Product> selectedProducts;
  
  const BulkPriceUpdatePage({super.key, required this.selectedProducts});

  @override
  State<BulkPriceUpdatePage> createState() => _BulkPriceUpdatePageState();
}

class _BulkPriceUpdatePageState extends State<BulkPriceUpdatePage> {
  final ProductRepository _repo = ProductRepository();
  TextEditingController? _newPriceController;
  double _percentageChange = 0.0;
  bool _usePercentage = false;
  bool _isProcessing = false;
  String? _lastError;
  int _updatedCount = 0;

  void _calculateNewPrice(double basePrice) {
    if (_usePercentage) {
      _newPriceController?.text = ((basePrice * (1 + _percentageChange / 100))).toStringAsFixed(2);
    } else {
      _newPriceController?.text = _newPriceController?.text ?? '0.00';
    }
  }

  Future<void> _confirmUpdate() async {
    if (_newPriceController?.text.isEmpty ?? true) {
      setState(() => _lastError = 'Ingrese un nuevo precio');
      return;
    }

    final newPrice = double.tryParse(_newPriceController!.text) ?? 0.0;
    
    if (newPrice <= 0) {
      setState(() => _lastError = 'El precio debe ser mayor a 0');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final ids = widget.selectedProducts.map((p) => p.id!).toList();
      final result = await _repo.cambiarPreciosMasivamente(ids, newPrice);
      
      setState(() {
        _updatedCount = result.length;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $result precios actualizados correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _lastError = e.toString());
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar Precios Masivamente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Información'),
                  content: Text(
                    'Se van a actualizar los precios de:\n\n'
                    '${widget.selectedProducts.length} productos\n\n'
                    '¿Desea continuar?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cerrar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Entendido'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen de selección
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Productos Seleccionados:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ...widget.selectedProducts.take(10).map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• ${p.nombre}', style: TextStyle(color: Colors.grey[600])),
                    )),
                    if (widget.selectedProducts.length > 10)
                      Text('...y ${widget.selectedProducts.length - 10} más'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Opción 1: Precio Fijo
            Card(
              child: RadioListTile<bool>(
                title: const Text('Poner precio fijo'),
                value: false,
                groupValue: _usePercentage,
                onChanged: (value) {
                  setState(() => _usePercentage = false!);
                  _calculateNewPrice(widget.selectedProducts.first.precioVenta);
                },
              ),
            ),
            const SizedBox(height: 8),
            
            TextField(
              controller: _newPriceController,
              decoration: const InputDecoration(
                labelText: 'Nuevo Precio (\$)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
                hintText: '0.00',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            
            // Opción 2: Porcentaje
            Card(
              child: RadioListTile<bool>(
                title: const Text('Incrementar/Reducir por porcentaje'),
                value: true,
                groupValue: _usePercentage,
                onChanged: (value) {
                  setState(() => _usePercentage = true!);
                  _calculateNewPrice(widget.selectedProducts.first.precioVenta);
                },
              ),
            ),
            const SizedBox(height: 8),
            
            TextField(
              decoration: const InputDecoration(
                labelText: 'Porcentaje (%)',
                prefixIcon: Icon(Icons.percent),
                border: OutlineInputBorder(),
                hintText: '0',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() => _percentageChange = double.tryParse(value) ?? 0.0);
                _calculateNewPrice(widget.selectedProducts.first.precioVenta);
              },
            ),
            const SizedBox(height: 16),
            
            // Error message
            if (_lastError != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red[50],
                child: Text('❌ $_lastError', style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 16),
            
            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _confirmUpdate,
                icon: _isProcessing
                    ? const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : const Icon(Icons.confirmation_number),
                label: _isProcessing
                    ? const Text('Procesando...')
                    : const Text('APLICAR CAMBIOS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _newPriceController?.dispose();
    super.dispose();
  }
}
