abstract class VentaRepository {
  Future<List<Map<String, dynamic>>> getAllVentas();
  Future<List<Map<String, dynamic>>> getVentasByDateRange(DateTime start, DateTime end);
  Future<int> createVenta(Map<String, dynamic> venta, List<Map<String, dynamic>> detalles);
  Future<bool> cancelVenta(int id);
  Future<double> getTotalVentasByDateRange(DateTime start, DateTime end);
}
