import 'package:flutter/material.dart';
import 'package:nova_aden/Dominio/entities/producto.dart';
import 'package:nova_aden/Nucleo/di/injection.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ProductoScreen extends StatefulWidget {
  const ProductoScreen({super.key});

  @override
  State<ProductoScreen> createState() => _ProductoScreenState();
}

class _ProductoScreenState extends State<ProductoScreen> {
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
    Navigator.pushNamed(context, '/producto_form').then((_) => _cargarProductos());
  }

  Future<void> _exportarCatalogoPDF() async {
    if (_productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay productos para exportar')),
      );
      return;
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Text('CATÁLOGO DE PRODUCTOS', style: pw.TextStyle(fontSize: 20)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Código', 'Nombre', 'Precio Venta', 'Stock'],
              data: _productos.map((p) => [
                p.codigo,
                p.nombre,
                p.precioVenta.toStringAsFixed(2),
                p.stock.toString(),
              ]).toList(),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportarCatalogoPDF,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _productos.isEmpty
              // ✅ Mensaje literal de HU_GP
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