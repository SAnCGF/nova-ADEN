class Product {
  final int? id;
  final String nombre;
  final String codigo;
  final double costo;
  final double precioVenta;
  final int stockActual;
  final int stockMinimo;
  final String unidadMedida;
  final String? categoria;

  Product({
    this.id,
    required this.nombre,
    required this.codigo,
    required this.costo,
    required this.precioVenta,
    required this.stockActual,
    required this.stockMinimo,
    required this.unidadMedida,
    this.categoria,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'costo': costo,
      'precioVenta': precioVenta,
      'stockActual': stockActual,
      'stockMinimo': stockMinimo,
      'unidadMedida': unidadMedida,
      'categoria': categoria,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      nombre: map['nombre'] ?? '',
      codigo: map['codigo'] ?? '',
      costo: (map['costo'] ?? 0).toDouble(),
      precioVenta: (map['precioVenta'] ?? 0).toDouble(),
      stockActual: map['stockActual'] ?? 0,
      stockMinimo: map['stockMinimo'] ?? 5,
      unidadMedida: map['unidadMedida'] ?? 'unidad',
      categoria: map['categoria'],
    );
  }
}
