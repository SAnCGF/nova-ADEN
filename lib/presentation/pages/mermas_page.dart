import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/repositories/product_repository.dart';

class MermasPage extends StatefulWidget {
  const MermasPage({super.key});

  @override
  State<MermasPage> createState() => _MermasPageState();
}

class _MermasPageState extends State<MermasPage> {
  final ProductRepository _productRepo = ProductRepository();
  List<Map<String, dynamic>> _productos = [];
  Map<int, String>? _motivoSelecionado;
  TextEditingController? _cantidadController;
  TextEditingController? _notaController;
  bool _isLoading = false;

  final List<Map<String, String>> _motivos = [
    {'key': 'deterioro', 'label': '🍂 Deterioro'},
    {'key': 'vencimiento', 'label': '⏰ Vencimiento'},
    {'key': 'robo', 'label': '🔒 Robo/Sustracción'},
    {'key': 'error_operativo', 'label': '❌ Error Operativo'},
    {'key': 'personalizado', 'label': '✏️ Personalizado'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProductos();
  }

  Future<void> _loadProductos() async {
    setState(() => _isLoading = true);
    try {
      final allProducts = await _productRepo.getAllProducts();
      setState(() {
        _productos = allProducts.map((p) => {
          'id': p.id,
          'nombre': p.nombre,
          'stockActual': p.stockActual,
          'codigo': p.codigo ?? '',
        }).toList();
      });
    } catch (e) {
      print('Error cargando productos: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _registrarMerma(int productId) async {
    if (_cantidadController?.text.isEmpty == true ||
        _motivoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Complete todos los campos'), backgroundColor: Colors.orange),
      );
      return;
    }

    final cantidad = int.tryParse(_cantidadController!.text) ?? 0;
    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Cantidad debe ser > 0'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      final db = await DatabaseHelper.instance.database;

      // Obtener detalles del producto para verificar stock
      final product = await _productRepo.getProductById(productId);
      if (product == null || product.stockActual < cantidad) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Stock insuficiente (${product?.stockActual ?? 0})'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Insertar merma en base de datos
      await db.insert('mermas', {
        'producto_id': productId,
        'cantidad': cantidad,
        'motivo': _motivoSelecionado!['key'],
        'fecha': DateTime.now().toIso8601String(),
      });

      // Actualizar stock del producto (reducir)
      await _productRepo.updateProductStock(productId, cantidad);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Merma registrada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _clearForm();
        _loadProductos();
      }
    } catch (e) {
      print('Error registrando merma: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _clearForm() {
    _cantidadController?.clear();
    _notaController?.clear();
    _motivoSelecionado = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Merma')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Buscar Producto', prefixIcon: Icon(Icons.search)),
              onChanged: (_) => _loadProductos(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Map<String, String>>(
              decoration: InputDecoration(labelText: 'Seleccionar Motivo'),
              items: _motivos.map((m) => DropdownMenuItem(value: m, child: Text(m['label']!))).toList(),
              onChanged: (val) {
                setState(() => _motivoSelecionado = val);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: _cantidadController?.text),
              decoration: InputDecoration(labelText: 'Cantidad', prefixIcon: Icon(Icons.numbers)),
              keyboardType: TextInputType.number,
              onChanged: (val) => _cantidadController = TextEditingController(text: val),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirmar Merma'),
                      content: const Text('¿Está seguro de registrar esta pérdida de stock?'),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('No'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 80,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Sí'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).then((_) {
                    _registrarMerma(_motivoSelecionado!.containsKey('key')
                        ? _productos.firstWhere((p) => p['id'].toString() ==
                            context.findRenderObject()
                            .debugGetOriginalTargetOf(RenderBox())).hashCode);
                  });
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('REGISTRAR MERMA'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
