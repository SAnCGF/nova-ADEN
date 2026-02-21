import 'package:flutter/material.dart';
import 'package:nova_aden/core/models/product.dart';
import 'package:nova_aden/core/repositories/product_repository.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = ProductRepository();
  
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _costController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;
  late final TextEditingController _unitController;
  late final TextEditingController _descriptionController;

  bool _isLoading = false;
  String? _codeError;

  @override
  void initState() {
    super.initState();
    
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name);
    _codeController = TextEditingController(text: p?.code);
    _costController = TextEditingController(text: p?.cost.toString());
    _priceController = TextEditingController(text: p?.price.toString());
    _stockController = TextEditingController(text: p?.stock.toString());
    _minStockController = TextEditingController(text: p?.minStock.toString());
    _unitController = TextEditingController(text: p?.unit ?? 'und');
    _descriptionController = TextEditingController(text: p?.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _costController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _unitController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Validar código único (solo para creación)
    if (widget.product == null) {
      final existing = await _repository.getProductByCode(_codeController.text);
      if (existing != null) {
        setState(() {
          _isLoading = false;
          _codeError = 'Este código ya está registrado';
        });
        return;
      }
    }

    final product = Product(
      id: widget.product?.id,
      name: _nameController.text.trim(),
      code: _codeController.text.trim().toUpperCase(),
      cost: double.tryParse(_costController.text) ?? 0,
      price: double.tryParse(_priceController.text) ?? 0,
      stock: int.tryParse(_stockController.text) ?? 0,
      minStock: int.tryParse(_minStockController.text) ?? 5,
      unit: _unitController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    final success = widget.product == null
        ? await _repository.createProduct(product)
        : await _repository.updateProduct(product);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null 
                ? 'Error al crear producto (código duplicado)' 
                : 'Error al actualizar producto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Eliminar'),
                    content: const Text('¿Eliminar este producto?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && mounted) {
                  await _repository.deleteProduct(widget.product!.id!);
                  Navigator.of(context).pop(true);
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nombre
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Producto *',
                        prefixIcon: Icon(Icons.label),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Código
                    TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: 'Código *',
                        prefixIcon: const Icon(Icons.qr_code),
                        errorText: _codeError,
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (v.length < 3) return 'Mínimo 3 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Precios
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _costController,
                            decoration: const InputDecoration(
                              labelText: 'Costo *',
                              prefixText: '\$',
                              prefixIcon: Icon(Icons.payments),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => v == null || v.isEmpty || double.tryParse(v) == null 
                                ? 'Número válido requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Precio Venta *',
                              prefixText: '\$',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => v == null || v.isEmpty || double.tryParse(v) == null 
                                ? 'Número válido requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Stock
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            decoration: const InputDecoration(
                              labelText: 'Stock Actual *',
                              prefixIcon: Icon(Icons.inventory),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty || int.tryParse(v) == null 
                                ? 'Número válido requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _minStockController,
                            decoration: const InputDecoration(
                              labelText: 'Stock Mínimo *',
                              prefixIcon: Icon(Icons.warning_amber),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty || int.tryParse(v) == null 
                                ? 'Número válido requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Unidad
                    TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unidad de Medida *',
                        hintText: 'ej: und, kg, lt, m',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
                    // Botón guardar
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A5F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(isEditing ? 'ACTUALIZAR' : 'GUARDAR PRODUCTO'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
