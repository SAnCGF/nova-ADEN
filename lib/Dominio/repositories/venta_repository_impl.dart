import 'package:nova_aden/Datos/datasources/app_database.dart';
import 'package:nova_aden/Dominio/entities/venta.dart';
import 'package:nova_aden/Dominio/repositories/venta_repository.dart';
import 'package:nova_aden/Dominio/repositories/producto_repository.dart';

class VentaConDetalles {
  final Venta venta;
  final List<DetalleVenta> detalles;

  VentaConDetalles({required this.venta, required this.detalles});
}

class VentaRepositoryImpl implements VentaRepository {
  final AppDatabase _db;
  final ProductoRepository _productoRepo;

  VentaRepositoryImpl(this._db, this._productoRepo);

  @override
  Future<int> registrarVenta(List<DetalleVenta> detalles) async {
    final now = DateTime.now();
    final ventaId = await _db.into(_db.ventas).insert(
      VentasCompanion(
        fecha: Value(now),
        total: Value(detalles.fold(0.0, (sum, d) => sum + d.subtotal)),
      ),
    );

    for (final detalle in detalles) {
      await _db.into(_db.detallesVenta).insert(
        DetallesVentaCompanion(
          ventaId: Value(ventaId),
          productoId: Value(detalle.producto.id),
          cantidad: Value(detalle.cantidad),
          precioUnitario: Value(detalle.precioUnitario),
        ),
      );

      final productoActual = await _productoRepo.obtenerPorId(detalle.producto.id);
      if (productoActual != null) {
        final nuevoStock = productoActual.stock - detalle.cantidad;
        await _productoRepo.guardar(productoActual.copyWith(stock: nuevoStock));
      }
    }

    return ventaId;
  }

  @override
  Future<List<Venta>> obtenerVentasDelDia() async {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);
    final fin = inicio.add(const Duration(days: 1));

    final ventas = await (_db.select(_db.ventas)
      ..where((v) => v.fecha.isBetweenValues(inicio, fin)))
      .get();

    return ventas.map((row) => Venta(
      id: row.id,
      fecha: row.fecha,
      total: row.total,
    )).toList();
  }

  @override
  Future<List<Venta>> obtenerVentasPorFechas(DateTime inicio, DateTime fin) async {
    final ventas = await (_db.select(_db.ventas)
      ..where((v) => v.fecha.isBetweenValues(inicio, fin)))
      .get();

    return ventas.map((row) => Venta(
      id: row.id,
      fecha: row.fecha,
      total: row.total,
    )).toList();
  }

  @override
  Future<VentaConDetalles> obtenerVentaConDetalles(int ventaId) async {
    // Obtener venta
    final ventaRow = await (_db.select(_db.ventas)..where((v) => v.id.equals(ventaId))).getSingle();
    final venta = Venta(id: ventaRow.id, fecha: ventaRow.fecha, total: ventaRow.total);

    // Obtener detalles
    final detallesRows = await (_db.select(_db.detallesVenta)..where((d) => d.ventaId.equals(ventaId))).get();
    final productos = await _productoRepo.obtenerTodos();
    final mapaProductos = {for (var p in productos) p.id: p};

    final detalles = detallesRows.map((row) {
      final producto = mapaProductos[row.productoId]!;
      return DetalleVenta(
        id: row.id,
        ventaId: row.ventaId,
        producto: producto,
        cantidad: row.cantidad,
        precioUnitario: row.precioUnitario,
      );
    }).toList();

    return VentaConDetalles(venta: venta, detalles: detalles);
  }
}// NO permitir actualización ni eliminación de ventas ya registradas
// Solo operaciones de lectura y creación
Future<List<Venta>> obtenerVentasDelDia() { ... }
Future<VentaConDetalles> obtenerVentaConDetalles(int ventaId) { ... }
// ¡NO hay métodos #2 updateVenta() ni deleteVenta()!