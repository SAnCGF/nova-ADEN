// test_db.dart
import 'package:nova_aden/Dominio/entities/producto.dart';
import 'Nucleo/di/injection.dart';

Future<void> main() async {
  await init();
  final repo = sl<ProductoRepository>();
  
  final id = await repo.guardar(Producto.nuevo(
    nombre: 'Arroz',
    precioCompra: 25.0,
    precioVenta: 30.0,
    stock: 100,
  ));

  final productos = await repo.obtenerTodos();
  print('✅ Productos: ${productos.length}, primer ID: $id');
}