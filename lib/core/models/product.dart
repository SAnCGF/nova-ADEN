class Product {
  final int? id;
  final String nombre;
  final String codigo;
  final double? costo;
  final double precioVenta;
  final int stockActual;
  final int stockMinimo;
  final String? categoria;
  final bool esFavorito;
  final int? stockCritico;
  final double? margenGanancia;
  final String unidadMedida;
  final bool activo;
  final String? notas;

  Product({
    this.id,
    required this.nombre,
    required this.codigo,
    this.costo,
    required this.precioVenta,
    required this.stockActual,
    required this.stockMinimo,
    this.categoria,
    this.esFavorito = false,
    this.stockCritico,
    this.margenGanancia,
    this.unidadMedida = 'UND',
    this.activo = true,
    this.notas,
  });

  bool get esStockCritico => stockCritico != null && stockActual <= stockCritico!;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'costo': costo,
      'precio_venta': precioVenta,
      'stock_actual': stockActual,
      'stock_minimo': stockMinimo,
      'categoria': categoria,
      'es_favorito': esFavorito ? 1 : 0,
      'stock_critico': stockCritico,
      'margen_ganancia': margenGanancia,
      'unidad_medida': unidadMedida,
      'activo': activo ? 1 : 0,
      'notas': notas,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      codigo: map['codigo'] as String,
      costo: map['costo'] as double?,
      precioVenta: map['precio_venta'] as double,
      stockActual: map['stock_actual'] as int,
      stockMinimo: map['stock_minimo'] as int,
      categoria: map['categoria'] as String?,
      esFavorito: map['es_favorito'] == 1,
      stockCritico: map['stock_critico'] as int?,
      margenGanancia: map['margen_ganancia'] as double?,
      unidadMedida: map['unidad_medida'] as String? ?? 'UND',
      activo: map['activo'] == 1,
      notas: map['notas'] as String?,
    );
  }
}
