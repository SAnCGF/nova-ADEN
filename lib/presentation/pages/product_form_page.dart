import 'package:flutter/material.dart';
import '../../core/models/product.dart';
import '../../core/repositories/product_repository.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;
  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _costoController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  final _unidadController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _repository = ProductRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nombreController.text = widget.product!.nombre;
      _codigoController.text = widget.product!.codigo;
      _costoController.text = widget.product!.costoPromedio.toString();
      _precioController.text = widget.product!.precioVenta.toString();
      _stockController.text = widget.product!.stockActual.toString();
      _stockMinimoController.text = widget.product!.stockMinimo.toString();
      _unidadController.text = widget.product!.unidadMedida;
      _descripcionController.text = widget.product!.descripcion ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _costoController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _stockMinimoController.dispose();
    _unidadController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final product = Product(
        id: widget.product?.id,
        nombre: _nombreController.text,
        codigo: _codigoController.text,
        costoPromedio: double.tryParse(_costoController.text) ?? 0,
        precioVenta: double.tryParse(_precioController.text) ?? 0,
        stockActual: int.tryParse(_stockController.text) ?? 0,
        stockMinimo: int.tryParse(_stockMinimoController.text) ?? 5,
        unidadMedida: _unidadController.text,
        descripcion: _descripcionController.text,
      );

      if (widget.product != null) {
        await _repository.updateProduct(widget.product!.id!, product);
      } else {
        await _repository.createProduct(product);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.product != null ? '✅ Producto actualizado' : '✅ Producto creado')),
        );
        Navigator.pop(context);
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
      appBar: AppBar(title: Text(widget.product != null ? 'Editar Producto' : 'Nuevo Producto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Requerido' : null),
            TextFormField(controller: _codigoController, decoration: const InputDecoration(labelText: 'Código de Barras', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Requerido' : null),
            TextFormField(controller: _costoController, decoration: const InputDecoration(labelText: 'Costo', prefixText: '\$ ', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            TextFormField(controller: _precioController, decoration: const InputDecoration(labelText: 'Precio Venta', prefixText: '\$ ', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            TextFormField(controller: _stockController, decoration: const InputDecoration(labelText: 'Stock', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            TextFormField(controller: _stockMinimoController, decoration: const InputDecoration(labelText: 'Stock Mínimo', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            TextFormField(controller: _unidadController, decoration: const InputDecoration(labelText: 'Unidad de Medida', border: OutlineInputBorder())),
            TextFormField(controller: _descripcionController, decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()), maxLines: 3),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _isLoading ? null : _save, child: const Text('Guardar')),
          ],
        ),
      ),
    );
  }
}
