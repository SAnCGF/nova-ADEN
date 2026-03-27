class Product {
  final int? id;
  final String nombre;
  final String codigo;
  final double? costo;
  final double precioVenta;
  final int stockActual;
  final int stockMinimo;

  Product({
    this.id,
    required this.nombre,
    required this.codigo,
    this.costo,
    required this.precioVenta,
    required this.stockActual,
    required this.stockMinimo,
  });

  // toMap: usa nombres de COLUMNAS de la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'costo': costo,
      'precio_venta': precioVenta,      // ← Columna en BD
      'stock_actual': stockActual,       // ← Columna en BD
      'stock_minimo': stockMinimo,       // ← Columna en BD
    };
  }

  // fromMap: lee de COLUMNAS de la base de datos
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      codigo: map['codigo'] as String,
      costo: (map['costo'] as num?)?.toDouble(),
      precioVenta: (map['precio_venta'] as num).toDouble(),  // ← Lee de columna BD
      stockActual: map['stock_actual'] as int,                // ← Lee de columna BD
      stockMinimo: map['stock_minimo'] as int,                // ← Lee de columna BD
    );
  }
}
