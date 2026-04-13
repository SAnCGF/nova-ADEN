import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/product.dart';
import '../models/sale.dart';

class PdfGenerator {
  // ✅ MÉTODO ORIGINAL: Generar catálogo de productos (MANTENIDO)
  static Future<void> generateProductCatalog(List<Product> products) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Catálogo de Productos - Nova ADEN')),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Código', 'Nombre', 'Precio', 'Stock'],
            data: products.map((p) => [
              p.codigo,
              p.nombre,
              '\$${p.precioVenta.toStringAsFixed(2)}',
              '${p.stockActual} ${p.unidadMedida}',
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
            },
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // ✅ MÉTODO CORREGIDO: Ticket de venta con nombre de empresa configurable
  static Future<void> generateSaleTicket(
    Sale sale, 
    List<SaleLine> lines, {
    String nombreEmpresa = 'Nova Aden', // ✅ Parámetro opcional con fallback
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ✅ Usar nombre configurable o fallback a 'Nova Aden'
              pw.Center(
                child: pw.Text(
                  nombreEmpresa.toUpperCase(), 
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Center(child: pw.Text('Ticket de Venta')),
              pw.Divider(),
              pw.Text('Fecha: ${sale.fecha.toString().split('.')[0]}'),
              if (sale.clienteId != null) pw.Text('Cliente ID: ${sale.clienteId}'),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: ['Cant', 'Producto', 'Subtotal'],
                data: lines.map((l) => [
                  '${l.cantidad}',
                  'Producto #${l.productoId}',
                  '\$${l.subtotal.toStringAsFixed(2)}',
                ]).toList(),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('\$${sale.total.toStringAsFixed(2)}', 
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text('¡Gracias por su compra!')),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
