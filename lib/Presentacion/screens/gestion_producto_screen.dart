cat > lib/Presentacion/screens/gestion_producto_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:nova_aden/Dominio/entities/producto.dart';
import 'package:nova_aden/Nucleo/di/injection.dart';

class GestionProductoScreen extends StatefulWidget {
  const GestionProductoScreen({super.key});

  @override
  State<GestionProductoScreen> createState() => _GestionProductoScreenState();
}

class _GestionProductoScreenState extends State<GestionProductoScreen> {
  late final repo = sl<ProductoRepository>();
  List<Producto> _productos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    try {
      _productos = await repo.obtenerTodos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar productos')),
      );
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _eliminarProducto(Producto producto) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Desea eliminar el producto "${producto.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await repo.eliminar(producto.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto eliminado')),
        );
        _cargarProductos();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar producto')),
        );
      }
    }
  }

  void _nuevoProducto() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormularioProductoScreen()),
    ).then((_) => _cargarProductos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Productos')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _productos.isEmpty
              // ✅ Mensaje literal de la HU_GP (Observación 3)
              ? const Center(child: Text('No hay productos registrados'))
              : ListView.builder(
                  itemCount: _productos.length,
                  itemBuilder: (context, index) {
                    final p = _productos[index];
                    return Card(
                      child: ListTile(
                        title: Text(p.nombre),
                        subtitle: Text('Código: ${p.codigo} | Stock: ${p.stock}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarProducto(p),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nuevoProducto,
        child: const Icon(Icons.add),
      ),
    );
  }
}
EOF