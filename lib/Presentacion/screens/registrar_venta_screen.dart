import 'package:flutter/material.dart';
import 'package:nova_aden/Dominio/entities/producto.dart';
import 'package:nova_aden/Dominio/entities/venta.dart';
import 'package:nova_aden/Nucleo/di/injection.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RegistrarVentaScreen extends StatefulWidget {
  const RegistrarVentaScreen({super.key});

  @override
  State<RegistrarVentaScreen> createState() => _RegistrarVentaScreenState();
}

class _RegistrarVentaScreenState extends State<RegistrarVentaScreen> {
  final _codigoCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController();
  final List<DetalleVenta> _carrito = [];
  double _total = 0.0;

  late final productoRepo = sl<ProductoRepository>();
  late final ventaRepo = sl<VentaRepository>();

  void _agregarProducto() async {
    final codigo = _codigoCtrl.text.trim();
    final cantidadStr = _cantidadCtrl.text.trim();

    if (codigo.isEmpty || cantidadStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código y cantidad son obligatorios')),
      );
      return;
    }

    final cantidad = int.tryParse(cantidadStr);
    if (cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cantidad debe ser un número positivo')),
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

    if (producto.stock < cantidad) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock insuficiente')),
      );
      return;
    }

    final detalle = DetalleVenta(
      id: 0,
      ventaId: 0,
      producto: producto,
      cantidad: cantidad,
      precioUnitario: producto.precioVenta,
    );

    setState(() {
      _carrito.add(detalle);
      _total += detalle.subtotal;
      _codigoCtrl.clear();
      _cantidadCtrl.clear();
    });
  }

  void _confirmarVenta() async {
    if (_carrito.isEmpty) {
      // ✅ Mensaje literal de HU_RV
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No existen productos agregados')),
      );
      return;
    }

    try {
      await ventaRepo.registrarVenta(_carrito);
      // ✅ Mensaje literal de HU_RV
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venta registrada satisfactoriamente')),
      );
      setState(() {
        _carrito.clear();
        _total = 0.0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar la venta')),
      );
    }
  }

  void _cancelarVenta() {
    // ✅ Al cancelar: no se registran cambios
    Navigator.pop(context);
  }

  Future<void> _exportarTicketPDF() async {
    if (_carrito.isEmpty) {
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
            pw.Text('TICKET DE VENTA', style: pw.TextStyle(fontSize: 20)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Producto', 'Cantidad', 'Precio', 'Subtotal'],
              data: _carrito.map((item) => [
                item.producto.nombre,
                item.cantidad.toString(),
                item.precioUnitario.toStringAsFixed(2),
                item.subtotal.toStringAsFixed(2),
              ]).toList(),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Total: $_total CUP', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
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
      appBar: AppBar(title: const Text('Registrar Venta')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codigoCtrl,
                    decoration: const InputDecoration(labelText: 'Código o nombre'),
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
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _agregarProducto,
                ),
              ],
            ),
          ),
          Expanded(
            child: _carrito.isEmpty
                ? const Center(child: Text('Carrito vacío'))
                : ListView.builder(
                    itemCount: _carrito.length,
                    itemBuilder: (context, index) {
                      final item = _carrito[index];
                      return ListTile(
                        title: Text(item.producto.nombre),
                        subtitle: Text('Cant: ${item.cantidad} | Subtotal: ${item.subtotal.toStringAsFixed(2)}'),
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
                        onPressed: _confirmarVenta,
                        icon: const Icon(Icons.check),
                        label: const Text('Confirmar venta'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _cancelarVenta,
                        icon: const Icon(Icons.close),
                        label: const Text('Cancelar'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // ✅ Botón de exportación a PDF (HU_RV)
                ElevatedButton.icon(
                  onPressed: _exportarTicketPDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Exportar ticket a PDF'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
Future<void> _exportarTicketPDF() async {
  final pdf = pw.Document();
  pdf.addPage(pw.Page(build: (context) => pw.Column(children: [
    pw.Text('COMPROBANTE FISCAL #${venta.id}'),
    pw.Text('Fecha: ${venta.fecha.toLocal()}'),
    // ... detalles ...
  ])));
  await Printing.layoutPdf(onLayout: (_) => pdf.save());
}