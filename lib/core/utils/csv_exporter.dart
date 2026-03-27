import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class CsvExporter {
  static Future<String> exportToCsv<T>(List<T> items, String fileName, List<String> headers, List<dynamic> Function(T) rowMapper) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName';
    final file = File(path);
    final csvData = [headers, ...items.map(rowMapper)];
    final csvString = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvString);
    return path;
  }
  static Future<String> exportProducts(List<Map<String, dynamic>> products) async {
    return exportToCsv(products, 'productos_${DateTime.now().millisecondsSinceEpoch}.csv',
      ['ID', 'Nombre', 'Codigo', 'Costo', 'PrecioVenta', 'StockActual', 'StockMinimo'],
      (p) => [p['id'], p['nombre'], p['codigo'], p['costo'], p['precio_venta'], p['stock_actual'], p['stock_minimo']]);
  }
}
