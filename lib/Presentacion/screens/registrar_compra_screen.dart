import 'package:flutter/material.dart';
import 'package:nova_aden/Dominio/entities/compra.dart';
import 'package:nova_aden/Dominio/entities/proveedor.dart';
import 'package:nova_aden/Nucleo/di/injection.dart';

class RegistrarCompraScreen extends StatefulWidget {
  const RegistrarCompraScreen({super.key});

  @override
  State<RegistrarCompraScreen> createState() => _RegistrarCompraScreenState();
}

class _RegistrarCompraScreenState extends State<RegistrarCompraScreen> {
  final _codigoCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final List<DetalleCompra> _carrito = [];
  double _total = 0.0;
  List<Proveedor> _proveedores = [];
  Proveedor? _proveedorSeleccionado;

  late final compraRepo = sl<CompraRepository>();
  late final productoRepo = sl<ProductoRepository>();

  @override
  void initState() {
    super.initState();
    _cargarProveedores();
  }

  Future<void> _cargarProveedores() async {
    _proveedores = await compraRepo.obtenerProveedores();
    if (_proveedores.isNotEmpty) {
      setState(() => _proveedorSeleccionado = _proveedores.first);
    }
  }

  void _agregarProducto() async {
    final codigo = _codigoCtrl.text.trim();
    final cantidadStr = _cantidadCtrl.text.trim();
    final precioStr = _precioCtrl.text.trim();

    if (codigo.isEmpty || cantidadStr.isEmpty || precioStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son obligatorios')),
      );
      return;
    }

    final cantidad = int.tryParse(cantidadStr);
    final precio = double.tryParse(precioStr);

    if (cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cantidad debe ser un número positivo')),
      );
      return;
    }

    if (precio == null || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El precio debe ser un número positivo')),
      );
      return;
    }

    final todos = await productoRepo.obtenerTodos();
    final producto = todos.firstWhere((p) => p.codigo == codigo, orElse: () => null);

    if (producto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto no encontrado')),
      );
      return;
    }

    final detalle = DetalleCompra(
      id: 0,
      compraId: 0,
      producto: producto,
      cantidad: cantidad,
      precioUnitario: precio,
    );

    setState(() {
      _carrito.add(detalle);
      _total += detalle.subtotal;
      _codigoCtrl.clear();
      _cantidadCtrl.clear();
      _precioCtrl.clear();
    });
  }

  void _confirmarCompra() async {
    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No existen productos agregados')),
      );
      return;
    }

    try {
      final proveedorId = _proveedorSeleccionado?.id;
      await compraRepo.registrarCompra(_carrito, proveedorId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compra registrada satisfactoriamente')),
      );
      setState(() {
        _carrito.clear();
        _total = 0.0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar la compra')),
      );
    }
  }

  void _cancelarCompra() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Compra')),
      body: Column(
        children: [
          // Selección de proveedor
          if (_proveedores.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<Proveedor>(
                value: _proveedorSeleccionado,
                items: _proveedores.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(p.nombre),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _proveedorSeleccionado = value),
                decoration: const InputDecoration(labelText: 'Proveedor (opcional)'),
              ),
            ),

          // Búsqueda de producto
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codigoCtrl,
                    decoration: const InputDecoration(labelText: 'Código'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _cantidadCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _precioCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Precio'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _agregarProducto,
                ),
              ],
            ),
          ),

          // Carrito
          Expanded(
            child: _carrito.isEmpty
                ? const Center(child: Text('Carrito vacío'))
                : ListView.builder(
                    itemCount: _carrito.length,
                    itemBuilder: (context, index) {
                      final item = _carrito[index];
                      return ListTile(
                        title: Text(item.producto.nombre),
                        subtitle: Text('Cant: ${item.cantidad} | Precio: ${item.precioUnitario}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _total -= item.subtotal;
                              _carrito.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),

          // Total y botones
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Total: $_total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _confirmarCompra,
                        icon: const Icon(Icons.check),
                        label: const Text('Confirmar compra'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _cancelarCompra,
                        icon: const Icon(Icons.close),
                        label: const Text('Cancelar'),
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