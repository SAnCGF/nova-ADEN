abstract class ProductoRepository {
  Future<List<Map<String, dynamic>>> getAllProductos();
  Future<Map<String, dynamic>?> getProductoById(int id);
  Future<int> createProducto(Map<String, dynamic> producto);
  Future<bool> updateProducto(int id, Map<String, dynamic> producto);
  Future<bool> deleteProducto(int id);
  Future<bool> updateStock(int id, double cantidad, bool esEntrada);
}
