import 'package:flutter/material.dart';
import '../../core/models/product.dart';
import '../../core/repositories/product_repository.dart';

class InventoryAdjustmentsPage extends StatefulWidget {
  const InventoryAdjustmentsPage({super.key});
  @override
  State<InventoryAdjustmentsPage> createState() => _InventoryAdjustmentsPageState();
}

class _InventoryAdjustmentsPageState extends State<InventoryAdjustmentsPage> {
  final _repo = ProductRepository();
  List<Product> _products = [];
  bool _loading = false;
  final Map<int, int> _adjustments = {};
  String _adjustmentType = 'positive';
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    _products = await _repo.getAllProducts();
    setState(() => _loading = false);
  }

  Future<void> _applyAdjustments() async {
    if (_adjustments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Seleccione productos'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Ingrese un motivo'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      for (final entry in _adjustments.entries) {
        final product = _products.firstWhere((p) => p.id == entry.key);
        final adjustment = _adjustmentType == 'positive' ? entry.value : -entry.value;
        final newStock = product.stockActual + adjustment;
        
        await _repo.updateProduct(
          product.id!,
          Product(
            nombre: product.nombre,
            codigo: product.codigo,
            costo: product.costo,
            precioVenta: product.precioVenta,
            stockActual: newStock,
            stockMinimo: product.stockMinimo,
            categoria: product.categoria,
            esFavorito: product.esFavorito,
            stockCritico: product.stockCritico,
            margenGanancia: product.margenGanancia,
          ),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Ajuste ${_adjustmentType == 'positive' ? 'positivo' : 'negativo'} aplicado'),
            backgroundColor: Colors.green,
          ),
        );
        _adjustments.clear();
        _reasonController.clear();
        await _loadProducts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes de Inventario'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipo de ajuste
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🔄 Tipo de Ajuste',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      setState(() => _adjustmentType = 'positive'),
                                  icon: const Icon(Icons.add_circle,
                                      color: Colors.green),
                                  label: const Text('Positivo (+)'),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: _adjustmentType == 'positive'
                                            ? Colors.green
                                            : Colors.grey),
                                    backgroundColor:
                                        _adjustmentType == 'positive'
                                            ? Colors.green[50]
                                            : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      setState(() => _adjustmentType = 'negative'),
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  label: const Text('Negativo (-)'),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: _adjustmentType == 'negative'
                                            ? Colors.red
                                            : Colors.grey),
                                    backgroundColor:
                                        _adjustmentType == 'negative'
                                            ? Colors.red[50]
                                            : null,
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

                  // Motivo
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📝 Motivo del Ajuste',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _reasonController,
                            decoration: const InputDecoration(
                              labelText: 'Motivo',
                              border: OutlineInputBorder(),
                              hintText: 'Ej: Conteo físico, Error de registro...',
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Productos
                  const Text('📦 Productos',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._products.map((p) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                p.stockActual > 0 ? Colors.blue : Colors.grey,
                            child: Icon(Icons.inventory_2, color: Colors.white),
                          ),
                          title: Text(p.nombre,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Stock actual: ${p.stockActual}'),
                              if (p.categoria != null)
                                Text('📁 ${p.categoria}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () => setState(() {
                                  _adjustments[p.id!] =
                                      (_adjustments[p.id!] ?? 0) - 1;
                                  if (_adjustments[p.id!] == 0) {
                                    _adjustments.remove(p.id);
                                  }
                                }),
                              ),
                              SizedBox(
                                width: 50,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  controller: TextEditingController(
                                      text: '${_adjustments[p.id] ?? 0}'),
                                  onChanged: (v) {
                                    final val = int.tryParse(v) ?? 0;
                                    if (val != 0) {
                                      setState(() => _adjustments[p.id!] = val);
                                    } else {
                                      setState(() => _adjustments.remove(p.id));
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle,
                                    color: Colors.green),
                                onPressed: () => setState(() {
                                  _adjustments[p.id!] =
                                      (_adjustments[p.id!] ?? 0) + 1;
                                }),
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 24),

                  // Resumen y botón aplicar
                  if (_adjustments.isNotEmpty)
                    Card(
                      color: _adjustmentType == 'positive'
                          ? Colors.green[50]
                          : Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Productos a ajustar: ${_adjustments.length}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _adjustmentType == 'positive'
                                      ? '➕ Sumar stock'
                                      : '➖ Restar stock',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _adjustmentType == 'positive'
                                          ? Colors.green[700]
                                          : Colors.red[700]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _applyAdjustments,
                                icon: const Icon(Icons.check_circle),
                                label: Text(
                                  'APLICAR AJUSTES',
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _adjustmentType == 'positive'
                                      ? Colors.green
                                      : Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
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
    _reasonController.dispose();
    super.dispose();
  }
}
