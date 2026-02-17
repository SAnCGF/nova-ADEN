import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io' show File;

part 'app_database.g.dart';

// Tabla: Productos
class Productos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codigo => text().withLength(min: 1, max: 50).unique()();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  RealColumn get precioCompra => real().check(precioCompra.isBiggerThan(0))();
  RealColumn get precioVenta => real().check(precioVenta.isBiggerThan(0))();
  IntColumn get stock => integer().check(stock.isBiggerOrEqual(0))();
}

// Tabla: Ventas
class Ventas extends Table {
  IntColumn get id => integer().autoIncrement()(); // ← Número de comprobante
  DateTimeColumn get fecha => dateTime().withDefault(currentDateAndTime)();
  RealColumn get total => real().check(total.isBiggerOrEqual(0))();
}


// Tabla: Detalles de Venta
class DetallesVenta extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ventaId => integer().references(Ventas, #id)();
  IntColumn get productoId => integer().references(Productos, #id)();
  IntColumn get cantidad => integer().check(cantidad.isBiggerThan(0))();
  RealColumn get precioUnitario => real().check(precioUnitario.isBiggerThan(0))();
}
// Tabla: Proveedores
class Proveedores extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  TextColumn get contacto => text().withLength(min: 0, max: 100).nullable()();
}

// Tabla: Compras
class Compras extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get proveedorId => integer().references(Proveedores, #id).nullable()();
  DateTimeColumn get fecha => dateTime().withDefault(currentDateAndTime)();
  RealColumn get total => real().check(total.isBiggerOrEqual(0))();
}

// Tabla: DetallesCompra
class DetallesCompra extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get compraId => integer().references(Compras, #id)();
  IntColumn get productoId => integer().references(Productos, #id)();
  IntColumn get cantidad => integer().check(cantidad.isBiggerThan(0))();
  RealColumn get precioUnitario => real().check(precioUnitario.isBiggerThan(0))();
}
// Base de datos principal
@DriftDatabase(tables: [Productos, Ventas, DetallesVenta, Proveedores, Compras, DetallesCompra])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

// Conexión a la base de datos (offline, en dispositivo)
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = p.join(dbFolder.path, 'nova_aden.db');
    return NativeDatabase.createInBackground(File(file));
  });
}