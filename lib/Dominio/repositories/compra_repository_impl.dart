import 'package:nova_aden/Datos/datasources/app_database.dart';
import 'package:nova_aden/Dominio/entities/compra.dart';
import 'package:nova_aden/Dominio/entities/proveedor.dart';
import 'package:nova_aden/Dominio/repositories/compra_repository.dart';
import 'package:nova_aden/Dominio/repositories/producto_repository.dart';

class CompraRepositoryImpl implements CompraRepository {
  final AppDatabase _db;
  final ProductoRepository _productoRepo;

  CompraRepositoryImpl(this._db, this._productoRepo);

  @override
  Future<List<Proveedor>> obtenerProveedores() async {
    final rows = await _db.select(_db.proveedores).get();
    return rows.map((row) => Proveedor(
      id: row.id,
      nombre: row.nombre,
      contacto: row.contacto,
    )).toList();
  }

  @override
  Future<int> guardarProveedor(Proveedor proveedor) async {
    return await _db.into(_db.proveedores).insertOnConflictUpdate(
      ProveedoresCompanion(
        id: proveedor.id == 0 ? null : Value(proveedor.id),
        nombre: Value(proveedor.nombre),
        contacto: Value(proveedor.contacto),
      ),
    );
  }

  @override
  Future<int> registrarCompra(List<DetalleCompra> detalles, int? proveedorId) async {
    final now = DateTime.now();
    final compraId = await _db.into(_db.compras).insert(
      ComprasCompanion(
        proveedorId: proveedorId != null ? Value(proveedorId) : const Value(null),
        fecha: Value(now),
        total: Value(detalles.fold(0.0, (sum, d) => sum + d.subtotal)),
      ),
    );

    for (final detalle in detalles) {
      await _db.into(_db.detallesCompra).insert(
        DetallesCompraCompanion(
          compraId: Value(compraId),
          productoId: Value(detalle.producto.id),
          cantidad: Value(detalle.cantidad),
          precioUnitario: Value(detalle.precioUnitario),
        ),
      );

      // Actualizar stock y costo promedio ponderado (RF 10, RF 50)
      final productoActual = await _productoRepo.obtenerPorId(detalle.producto.id);
      if (productoActual != null) {
        final nuevoStock = productoActual.stock + detalle.cantidad;
        // Simplificación: actualizamos solo stock; costo promedio se calcula en reportes
        await _productoRepo.guardar(productoActual.copyWith(stock: nuevoStock));
      }
    }

    return compraId;
  }
}