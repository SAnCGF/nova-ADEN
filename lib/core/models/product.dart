class Product {
  final int? id;
  final String nombre;
  final String codigo;
  final double costoPromedio;
  final bool isFavorite;
  final double precioVenta;
  final int stockActual;
  final int stockMinimo;
  final String unidadMedida;
  final bool isActive;
  final String? descripcion;
  final bool activo;

  Product({
    this.id,
    required this.nombre,
    required this.codigo,
    required this.costoPromedio,
    this.isFavorite = false,
    required this.precioVenta,
    required this.stockActual,
    required this.stockMinimo,
    required this.unidadMedida,
    this.isActive = true,
    this.descripcion,
    this.activo = true,
  });

  // Alias para compatibilidad
  String get name => nombre;
  String get code => codigo;
  double get cost => costoPromedio;
  double get price => precioVenta;
  int get stock => stockActual;
  int get minStock => stockMinimo;
  String get unit => unidadMedida;
  String? get description => descripcion;
  bool get isLowStock => stockActual <= stockMinimo;
  double get margen => precioVenta - costoPromedio;
  double get valorInventario => stockActual * costoPromedio;

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      nombre: map['nombre'] ?? '',
      codigo: map['codigo_barras'] ?? map['codigo'] ?? '',
      costoPromedio: (map['precio_compra'] ?? map['costoPromedio'] ?? 0).toDouble(),
      precioVenta: (map['precio_venta'] ?? map['precioVenta'] ?? 0).toDouble(),
      stockActual: (map['stock'] ?? map['stockActual'] ?? 0).toInt(),
      stockMinimo: (map['stock_minimo'] ?? map['stockMinimo'] ?? 5).toInt(),
      unidadMedida: map['unidad_medida'] ?? map['unidadMedida'] ?? 'UNIDAD',
      descripcion: map['descripcion'],
      activo: map['activo'] == 1 || map['activo'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo_barras': codigo,
      'precio_compra': costoPromedio,
      'precio_venta': precioVenta,
      'stock': stockActual,
      'stock_minimo': stockMinimo,
      'unidad_medida': unidadMedida,
      'descripcion': descripcion,
      'activo': activo ? 1 : 0,
    };
  }

  Product copyWith({
    int? id,
    String? nombre,
    String? codigo,
    double? costoPromedio,
    double? precioVenta,
    int? stockActual,
    int? stockMinimo,
    String? unidadMedida,
    String? descripcion,
    bool? activo,
  }) {
    return Product(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      costoPromedio: costoPromedio ?? this.costoPromedio,
      precioVenta: precioVenta ?? this.precioVenta,
      stockActual: stockActual ?? this.stockActual,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
    );
  }
}
