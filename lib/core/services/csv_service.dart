import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../models/product.dart';

class CsvService {
  Future<List<Product>> importProductsFromCsv(File file) async {
    try {
      final input = file.openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(CsvToListConverter())
          .toList();
      
      final products = <Product>[];
      for (var i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.length >= 5) {
          products.add(Product(
            id: null,
            codigo: row[0]?.toString() ?? '',
            nombre: row[1]?.toString() ?? '',
            descripcion: row[2]?.toString() ?? '',
            costoPromedio: double.tryParse(row[3]?.toString() ?? '0') ?? 0.0,
            precioVenta: double.tryParse(row[4]?.toString() ?? '0') ?? 0.0,
            stockActual: int.tryParse(row[5]?.toString() ?? '0') ?? 0,
            stockMinimo: int.tryParse(row[6]?.toString() ?? '0') ?? 0,
            unidadMedida: row[7]?.toString() ?? 'unidad',
          ));
        }
      }
      return products;
    } catch (e) {
      throw Exception('Error al importar CSV: $e');
    }
  }

  Future<File> exportProductsToCsv(List<Product> products) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/catalogo_productos.csv';
      final file = File(filePath);
      
      final csvData = List<List<dynamic>>.generate(
        products.length + 1,
        (index) {
          if (index == 0) {
            return ['Código', 'Nombre', 'Descripción', 'Costo', 'Precio', 'Stock', 'Stock Mín', 'Unidad'];
          }
          final p = products[index - 1];
          return [p.codigo, p.nombre, p.descripcion, p.costoPromedio, p.precioVenta, p.stockActual, p.stockMinimo, p.unidadMedida];
        },
      );
      
      await file.writeAsString(const ListToCsvConverter().convert(csvData));
      return file;
    } catch (e) {
      throw Exception('Error al exportar CSV: $e');
    }
  }
}
