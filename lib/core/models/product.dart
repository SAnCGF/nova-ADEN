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
  // RF 51: Margen de ganancia sugerido
  final double? margenGanancia;

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
  });

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
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      codigo: map['codigo'] as String,
      costo: (map['costo'] as num?)?.toDouble(),
      precioVenta: (map['precio_venta'] as num).toDouble(),
      stockActual: map['stock_actual'] as int,
      stockMinimo: map['stock_minimo'] as int,
      categoria: map['categoria'] as String?,
      esFavorito: (map['es_favorito'] as int?) == 1,
      stockCritico: map['stock_critico'] as int?,
      margenGanancia: (map['margen_ganancia'] as num?)?.toDouble(),
    );
  }

  // RF 51: Calcular precio sugerido por margen
  double calcularPrecioSugerido(double margen) {
    final costoReal = costo ?? 0.0;
    return costoReal > 0 ? costoReal * (1 + margen / 100) : precioVenta;
  }

  // RF 51: Obtener margen actual
  double get margenActual {
    final costoReal = costo ?? 0.0;
    if (costoReal <= 0) return 0.0;
    return ((precioVenta - costoReal) / costoReal) * 100;
  }

  bool get esStockCritico => stockCritico != null ? stockActual <= stockCritico! : stockActual <= stockMinimo;
}
