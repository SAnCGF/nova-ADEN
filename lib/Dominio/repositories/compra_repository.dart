import '../entities/compra.dart';
import '../entities/proveedor.dart';

abstract class CompraRepository {
  Future<List<Proveedor>> obtenerProveedores();
  Future<int> guardarProveedor(Proveedor proveedor);
  Future<int> registrarCompra(List<DetalleCompra> detalles, int? proveedorId);
}