class Product {
  final int? id;
  final String name;
  final String code;
  final double cost;
  final double price;
  final int stock;
  final int minStock;
  final String unit;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.id,
    required this.name,
    required this.code,
    required this.cost,
    required this.price,
    required this.stock,
    required this.minStock,
    required this.unit,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convertir Product a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'cost': cost,
      'price': price,
      'stock': stock,
      'min_stock': minStock,
      'unit': unit,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crear Product desde Map de SQLite
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      cost: map['cost'],
      price: map['price'],
      stock: map['stock'],
      minStock: map['min_stock'],
      unit: map['unit'],
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// Copiar producto con cambios (para edición)
  Product copyWith({
    int? id,
    String? name,
    String? code,
    double? cost,
    double? price,
    int? stock,
    int? minStock,
    String? unit,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      cost: cost ?? this.cost,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Verificar si el stock está bajo el mínimo
  bool get isLowStock => stock < minStock;

  @override
  String toString() {
    return 'Product{id: $id, name: $name, code: $code, stock: $stock}';
  }
}
