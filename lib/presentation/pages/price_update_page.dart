import 'package:flutter/material.dart';
import 'package:nova_aden/core/repositories/settings_repository.dart';

class PriceUpdatePage extends StatefulWidget {
  const PriceUpdatePage({super.key});

  @override
  State<PriceUpdatePage> createState() => _PriceUpdatePageState();
}

class _PriceUpdatePageState extends State<PriceUpdatePage> {
  final SettingsRepository _repository = SettingsRepository();
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

  Future<void> _updatePrices() async {
    final value = double.tryParse(_valueController.text);
    if (value == null || value <= 0) {
      _showSnackBar('Ingresa un valor válido', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Actualización'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtro: ${_getFilterLabel()}'),
            Text('Tipo: ${_increase ? "Aumento" : "Disminución"}'),
            Text('Valor: ${_updateType == 'percentage' ? '$value%' : '\$${value.toStringAsFixed(2)}'}'),
            const SizedBox(height: 16),
            const Text('⚠️ Esta acción no se puede deshacer', style: TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    final success = await _repository.updatePricesMassively(
      filterType: _filterType,
      updateType: _updateType,
      value: value,
      increase: _increase,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      _showSnackBar('✅ Precios actualizados exitosamente');
      Navigator.pop(context);
    } else {
      _showSnackBar('Error al actualizar precios', isError: true);
    }
  }

  String _getFilterLabel() {
    switch (_filterType) {
      case 'all': return 'Todos los productos';
      case 'low_stock': return 'Productos con stock bajo';
      case 'high_stock': return 'Productos con stock alto';
      default: return 'Todos';
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actualizar Precios Masivamente')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Filtro
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Filtrar Productos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ...['all', 'low_stock', 'high_stock'].map((filter) => RadioListTile<String>(
                            title: Text(_getFilterLabelFor(filter)),
                            value: filter,
                            groupValue: _filterType,
                            onChanged: (v) => setState(() => _filterType = v!),
                          )),
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
                          const Text('Tipo de Actualización', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Porcentaje'),
                                  subtitle: const Text('Ej: 10%'),
                                  value: 'percentage',
                                  groupValue: _updateType,
                                  onChanged: (v) => setState(() => _updateType = v!),
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Valor Fijo'),
                                  subtitle: const Text('Ej: \$5.00'),
                                  value: 'fixed',
                                  groupValue: _updateType,
                                  onChanged: (v) => setState(() => _updateType = v!),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Aumento o disminución
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dirección', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => setState(() => _increase = true),
                                  icon: const Icon(Icons.trending_up),
                                  label: const Text('Aumentar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _increase ? Colors.green : Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => setState(() => _increase = false),
                                  icon: const Icon(Icons.trending_down),
                                  label: const Text('Disminuir'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: !_increase ? Colors.red : Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
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
                          const Text('Valor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _valueController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: _updateType == 'percentage' ? 'Porcentaje (%)' : 'Valor (\$)',
                              prefixText: _updateType == 'percentage' ? '' : '\$',
                              suffixText: _updateType == 'percentage' ? '%' : '',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              hintText: _updateType == 'percentage' ? 'Ej: 10' : 'Ej: 5.00',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Botón confirmar
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updatePrices,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('ACTUALIZAR PRECIOS', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _getFilterLabelFor(String filter) {
    switch (filter) {
      case 'all': return 'Todos los productos';
      case 'low_stock': return 'Productos con stock bajo';
      case 'high_stock': return 'Productos con stock alto';
      default: return 'Todos';
    }
  }
}
