import 'package:flutter/material.dart';
import '../../core/repositories/product_repository.dart';

class PriceUpdatePage extends StatefulWidget {
  const PriceUpdatePage({super.key});

  @override
  State<PriceUpdatePage> createState() => _PriceUpdatePageState();
}

class _PriceUpdatePageState extends State<PriceUpdatePage> {
  final ProductRepository _repository = ProductRepository();
  final TextEditingController _valueController = TextEditingController();
  
  String _filterType = 'all';
  String _updateType = 'percentage';
  bool _increase = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  String _getFilterLabel(String type) {
    switch (type) {
      case 'all': return 'Todos los productos';
      case 'low_stock': return 'Productos con stock bajo';
      case 'high_stock': return 'Productos con stock alto';
      default: return 'Todos';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualización Masiva de Precios'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtro de productos
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filtrar Productos',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          RadioListTile<String>(
                            title: const Text('Todos los productos'),
                            value: 'all',
                            groupValue: _filterType,
                            onChanged: (v) => setState(() => _filterType = v!),
                          ),
                          RadioListTile<String>(
                            title: const Text('Productos con stock bajo'),
                            value: 'low_stock',
                            groupValue: _filterType,
                            onChanged: (v) => setState(() => _filterType = v!),
                          ),
                          RadioListTile<String>(
                            title: const Text('Productos con stock alto'),
                            value: 'high_stock',
                            groupValue: _filterType,
                            onChanged: (v) => setState(() => _filterType = v!),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tipo de actualización
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tipo de Actualización',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => setState(() => _updateType = 'percentage'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _updateType == 'percentage' ? Colors.blue : Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Porcentaje (%)'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => setState(() => _updateType = 'value'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _updateType == 'value' ? Colors.blue : Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Valor Fijo (\$)'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Aumento o Disminución
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Operación',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => setState(() => _increase = true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _increase ? Colors.green : Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Aumentar'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => setState(() => _increase = false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: !_increase ? Colors.red : Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Disminuir'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Valor
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Valor',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _valueController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: _updateType == 'percentage' ? 'Porcentaje (%)' : 'Valor (\$)',
                              prefixText: _updateType == 'percentage' ? '' : '\$ ',
                              suffixText: _updateType == 'percentage' ? '%' : '',
                              hintText: _updateType == 'percentage' ? 'Ej: 10' : 'Ej: 5.00',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Botón Actualizar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _updatePrices,
                      icon: const Icon(Icons.update),
                      label: const Text(
                        'ACTUALIZAR PRECIOS',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _updatePrices() async {
    final value = double.tryParse(_valueController.text);
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Ingresa un valor válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _repository.updatePricesMassively(
        filterType: _filterType,
        updateType: _updateType,
        value: value,
        increase: _increase,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result ? '✅ Precios actualizados' : '❌ Error al actualizar'),
            backgroundColor: result ? Colors.green : Colors.red,
          ),
        );
        if (result) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
