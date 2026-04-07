import 'package:flutter/material.dart';
import '../../core/models/product.dart';
import '../../core/repositories/product_repository.dart';
import '../../core/utils/pdf_generator.dart';

class ProductListPage extends StatefulWidget {
  final VoidCallback? onStatsChanged;
  const ProductListPage({super.key, this.onStatsChanged});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _repo = ProductRepository();
  List<Product> _products = [];
  bool _loading = true;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _products = await _repo.getAllProducts();
    setState(() => _loading = false);
  }

  Future<void> _exportPdf() async {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ No hay productos para exportar')),
      );
      return;
    }
    try {
      await PdfGenerator.generateProductCatalog(_products);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al generar PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Validación de Código Único
  Future<bool> _isCodeUnique(String code, {int? excludeId}) async {
    final all = await _repo.getAllProducts();
    final exists = all.any((p) => p.codigo == code && p.id != excludeId);
    return !exists;
  }

  Future<void> _deleteProduct(int id) async {
    // Confirmación Explícita (Requisito HU_GP)
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Está seguro que desea eliminar este producto? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _repo.deleteProduct(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Producto eliminado satisfactoriamente'), backgroundColor: Colors.green),
          );
          _load();
          if (widget.onStatsChanged != null) widget.onStatsChanged!();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showProductForm({Product? product}) {
    final nombreCtrl = TextEditingController(text: product?.nombre ?? '');
    final codigoCtrl = TextEditingController(text: product?.codigo ?? '');
    final costoCtrl = TextEditingController(text: product?.costo?.toString() ?? '');
    final precioCtrl = TextEditingController(text: product?.precioVenta.toString() ?? '');
    final stockCtrl = TextEditingController(text: product?.stockActual.toString() ?? '0');
    final stockMinCtrl = TextEditingController(text: product?.stockMinimo.toString() ?? '5');
    final categoriaCtrl = TextEditingController(text: product?.categoria ?? '');
    final stockCriticoCtrl = TextEditingController(text: product?.stockCritico?.toString() ?? '2');
    final margenCtrl = TextEditingController(text: product?.margenGanancia?.toString() ?? '30');
    final unidadCtrl = TextEditingController(text: product?.unidadMedida ?? 'UND');
    final notasCtrl = TextEditingController(text: product?.notas ?? '');
    bool esFavorito = product?.esFavorito ?? false;
    double precioSugerido = 0.0;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.95,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollCtrl) => SingleChildScrollView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product == null ? '➕ Nuevo Producto' : '✏️ Editar Producto',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                    ),
                    IconButton(icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black87), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                TextField(
                  controller: nombreCtrl,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Nombre *',
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: codigoCtrl,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Código *',
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: unidadCtrl,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Unidad Medida',
                          labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: categoriaCtrl,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Categoría',
                          labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: costoCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Costo',
                          labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                        ),
                        onChanged: (v) {
                          final costo = double.tryParse(v) ?? 0.0;
                          final margen = double.tryParse(margenCtrl.text) ?? 30.0;
                          precioSugerido = costo > 0 ? costo * (1 + margen / 100) : 0.0;
                          setModalState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: precioCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Precio Venta *',
                          labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Stock Actual',
                          labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: stockMinCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Stock Mínimo',
                          labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notasCtrl,
                  maxLines: 2,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Notas / Componentes',
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Validaciones HU_GP
                      if (nombreCtrl.text.isEmpty || codigoCtrl.text.isEmpty || precioCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('⚠️ Complete los campos obligatorios'), backgroundColor: Colors.orange),
                        );
                        return;
                      }

                      final costo = double.tryParse(costoCtrl.text) ?? 0.0;
                      final precio = double.tryParse(precioCtrl.text);
                      final stock = int.tryParse(stockCtrl.text) ?? 0;
                      final stockMin = int.tryParse(stockMinCtrl.text) ?? 0;

                      if (precio == null || precio <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('⚠️ El precio debe ser un valor positivo'), backgroundColor: Colors.orange),
                        );
                        return;
                      }
                      if (stock < 0 || stockMin < 0) {
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('⚠️ El stock debe ser un valor positivo'), backgroundColor: Colors.orange),
                        );
                        return;
                      }

                      final isUnique = await _isCodeUnique(codigoCtrl.text, excludeId: product?.id);
                      if (!isUnique) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('⚠️ El código del producto ya existe'), backgroundColor: Colors.orange),
                        );
                        return;
                      }

                      try {
                        final newProduct = Product(
                          id: product?.id,
                          nombre: nombreCtrl.text.trim(),
                          codigo: codigoCtrl.text.trim(),
                          costo: costo,
                          precioVenta: precio,
                          stockActual: stock,
                          stockMinimo: stockMin,
                          categoria: categoriaCtrl.text.trim().isEmpty ? null : categoriaCtrl.text.trim(),
                          esFavorito: esFavorito,
                          stockCritico: int.tryParse(stockCriticoCtrl.text),
                          margenGanancia: double.tryParse(margenCtrl.text),
                          unidadMedida: unidadCtrl.text.trim().isEmpty ? 'UND' : unidadCtrl.text.trim(),
                          activo: product?.activo ?? true,
                          notas: notasCtrl.text.trim().isEmpty ? null : notasCtrl.text.trim(),
                        );
                        if (product == null) {
                          await _repo.createProduct(newProduct);
                        } else {
                          await _repo.updateProduct(product.id!, newProduct);
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(product == null ? '✅ Producto registrado satisfactoriamente' : '✅ Producto actualizado'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(ctx);
                          _load();
                          if (widget.onStatsChanged != null) widget.onStatsChanged!();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: Text(
                      product == null ? 'CREAR' : 'ACTUALIZAR',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredList = _products.where((p) =>
      p.nombre.toLowerCase().contains(_search.text.toLowerCase()) ||
      p.codigo.toLowerCase().contains(_search.text.toLowerCase()) ||
      (p.categoria?.toLowerCase().contains(_search.text.toLowerCase()) ?? false)
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: _exportPdf, tooltip: 'Exportar Catálogo PDF'),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _search,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, código o categoría...',
                      hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                      prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.grey),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(child: Text('No hay productos registrados', style: TextStyle(color: isDark ? Colors.white70 : Colors.grey, fontSize: 18)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredList.length,
                          itemBuilder: (ctx, i) {
                            final p = filteredList[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(backgroundColor: p.activo ? (p.stockActual > 0 ? Colors.blue : Colors.grey) : Colors.grey[400], child: const Icon(Icons.inventory_2, color: Colors.white)),
                                title: Text(p.nombre, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Código: ${p.codigo}', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
                                  Text('Stock: ${p.stockActual} ${p.unidadMedida}', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
                                  Text('\$${p.precioVenta.toStringAsFixed(2)}', style: TextStyle(color: Colors.green[400], fontWeight: FontWeight.bold)),
                                ]),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _showProductForm(product: p)),
                                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteProduct(p.id!)),
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

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }
}
