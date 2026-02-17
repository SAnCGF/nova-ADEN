cat > lib/Presentacion/screens/formulario_producto_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:nova_aden/Dominio/entities/producto.dart';
import 'package:nova_aden/Nucleo/di/injection.dart';

class FormularioProductoScreen extends StatefulWidget {
  const FormularioProductoScreen({super.key});

  @override
  State<FormularioProductoScreen> createState() =>
      _FormularioProductoScreenState();
}

class _FormularioProductoScreenState extends State<FormularioProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _compraCtrl = TextEditingController();
  final _ventaCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();

  final repo = sl<ProductoRepository>();

  Future<bool> _esCodigoUnico(String codigo) async {
    final todos = await repo.obtenerTodos();
    return !todos.any((p) => p.codigo.toLowerCase() == codigo.toLowerCase());
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final codigo = _codigoCtrl.text.trim();
    final nombre = _nombreCtrl.text.trim();
    final compra = double.tryParse(_compraCtrl.text) ?? 0;
    final venta = double.tryParse(_ventaCtrl.text) ?? 0;
    final stock = int.tryParse(_stockCtrl.text) ?? 0;

    // ✅ Validaciones según HU_GP (Observaciones 4, 5, 6)
    if (compra <= 0 || venta <= 0 || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Los valores numéricos deben ser positivos')),
      );
      return;
    }

    final esUnico = await _esCodigoUnico(codigo);
    if (!esUnico) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El código del producto ya existe')),
      );
      return;
    }

    final producto = Producto.nuevo(
      codigo: codigo,
      nombre: nombre,
      precioCompra: compra,
      precioVenta: venta,
      stock: stock,
    );

    try {
      await repo.guardar(producto);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto registrado correctamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el producto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _codigoCtrl,
                decoration: const InputDecoration(labelText: 'Código *'),
                validator: (v) => v!.trim().isEmpty ? 'Este campo es obligatorio' : null,
              ),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre *'),
                validator: (v) => v!.trim().isEmpty ? 'Este campo es obligatorio' : null,
              ),
              TextFormField(
                controller: _compraCtrl,
                decoration: const InputDecoration(labelText: 'Precio compra *'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              TextFormField(
                controller: _ventaCtrl,
                decoration: const InputDecoration(labelText: 'Precio venta *'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              TextFormField(
                controller: _stockCtrl,
                decoration: const InputDecoration(labelText: 'Stock *'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardar,
                child: const Text('Guardar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF