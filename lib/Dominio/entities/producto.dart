class Producto {
  final int id;
  final String codigo;
  final String nombre;
  final double precioCompra;
  final double precioVenta;
  final int stock;

  Producto({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.precioCompra,
    required this.precioVenta,
    required this.stock,
  });

  factory Producto.nuevo({
    required String codigo,
    required String nombre,
    required double precioCompra,
    required double precioVenta,
    required int stock,
  }) {
    return Producto(
      id: 0,
      codigo: codigo,
      nombre: nombre,
      precioCompra: precioCompra,
      precioVenta: precioVenta,
      stock: stock,
    );
  }

  Producto copyWith({
    int? id,
    String? codigo,
    String? nombre,
    double? precioCompra,
    double? precioVenta,
    int? stock,
  }) {
    return Producto(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      precioCompra: precioCompra ?? this.precioCompra,
      precioVenta: precioVenta ?? this.precioVenta,
      stock: stock ?? this.stock,
    );
  }
}