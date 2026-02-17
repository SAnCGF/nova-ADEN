import 'package:get_it/get_it.dart';
import 'package:nova_aden/Datos/datasources/app_database.dart';
import 'package:nova_aden/Datos/repositories/producto_repository_impl.dart';
import 'package:nova_aden/Datos/repositories/venta_repository_impl.dart';
import 'package:nova_aden/Dominio/repositories/producto_repository.dart';
import 'package:nova_aden/Dominio/repositories/venta_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final db = AppDatabase();
  final productoRepo = ProductoRepositoryImpl(db);
  sl.registerSingleton<AppDatabase>(db);
  sl.registerSingleton<ProductoRepository>(productoRepo);
  sl.registerSingleton<VentaRepository>(VentaRepositoryImpl(db, productoRepo));
}