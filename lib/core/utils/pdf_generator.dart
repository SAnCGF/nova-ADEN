import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/sale.dart';
import '../models/sale_line.dart';

class PdfGenerator {
  // ✅ MÉTODO PRINCIPAL: Generar ticket de venta en PDF
  static Future<File?> generateSaleTicket({
    required Sale sale,
    required List<SaleLine> lines,
    String nombreEmpresa = 'Nova Aden',
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Encabezado
                pw.Center(
                  child: pw.Text(
                    nombreEmpresa.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Text(
                    'TICKET DE VENTA',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 5),
                
                // Información de la venta
                pw.Text('No. Venta: ${sale.id}'),
                pw.Text('Fecha: ${_formatDate(sale.fecha)}'),
                if (sale.clienteId != null)
                  pw.Text('Cliente ID: ${sale.clienteId}'),
                pw.Text('Moneda: ${sale.moneda}'),
                pw.SizedBox(height: 10),
                
                pw.Divider(),
                pw.SizedBox(height: 5),
                
                // Tabla de productos
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    // Encabezados de tabla
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Cant', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Producto', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Subtotal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                        ),
                      ],
                    ),
                    // Líneas de productos
                    ...lines.map((line) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('${line.cantidad}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Prod #${line.productoId}', style: pw.TextStyle(fontSize: 10)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              '\$${line.subtotal.toStringAsFixed(2)}',
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 5),
                
                // Totales
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL:',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '\$${sale.total.toStringAsFixed(2)} ${sale.moneda}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                if (sale.montoPagado > 0) ...[
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Pagado:'),
                      pw.Text('\$${sale.montoPagado.toStringAsFixed(2)}'),
                    ],
                  ),
                ],
                
                if (sale.montoPendiente > 0) ...[
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Pendiente:', style: pw.TextStyle(color: PdfColors.red)),
                      pw.Text('\$${sale.montoPendiente.toStringAsFixed(2)}', style: pw.TextStyle(color: PdfColors.red)),
                    ],
                  ),
                ],
                
                pw.SizedBox(height: 15),
                pw.Divider(),
                pw.SizedBox(height: 10),
                
                // Pie
                pw.Center(
                  child: pw.Text(
                    '¡Gracias por su compra!',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Text(
                    nova-ADEN - Sistema de Gestión',
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Guardar archivo
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/ticket_venta_${sale.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Imprimir o compartir
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'ticket_venta_${sale.id}.pdf',
      );

      return file;
    } catch (e) {
      print('❌ Error generando PDF: $e');
      return null;
    }
  }

  // ✅ Helper: Formatear fecha
  static String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // ✅ MÉTODO ADICIONAL: Generar catálogo de productos (para RF 47)
  static Future<void> generateProductCatalog(List<dynamic> products) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Catálogo de Productos - Nova ADEN')),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Código', 'Nombre', 'Precio', 'Stock'],
            data: products.map((p) => [
              p.codigo ?? '',
              p.nombre,
              '\$${(p.precioVenta ?? 0).toStringAsFixed(2)}',
              '${p.stockActual ?? 0} ${p.unidadMedida ?? "und"}',
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
}
