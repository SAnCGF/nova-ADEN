import 'package:nova_aden/Dominio/entities/venta.dart';

abstract class VentaRepository {
  Future<int> registrarVenta(List<DetalleVenta> detalles);
  Future<List<Venta>> obtenerVentasDelDia();
  Future<List<Venta>> obtenerVentasPorFechas(DateTime inicio, DateTime fin);
  Future<VentaConDetalles> obtenerVentaConDetalles(int ventaId);
}