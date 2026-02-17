// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductosTable extends Productos
    with TableInfo<$ProductosTable, Producto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioCompraMeta = const VerificationMeta(
    'precioCompra',
  );
  @override
  late final GeneratedColumn<double> precioCompra = GeneratedColumn<double>(
    'precio_compra',
    aliasedName,
    false,
    check: () => ComparableExpr(precioCompra).isBiggerThan(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioVentaMeta = const VerificationMeta(
    'precioVenta',
  );
  @override
  late final GeneratedColumn<double> precioVenta = GeneratedColumn<double>(
    'precio_venta',
    aliasedName,
    false,
    check: () => ComparableExpr(precioVenta).isBiggerThan(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
    'stock',
    aliasedName,
    false,
    check: () => ComparableExpr(stock).isBiggerOrEqual(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codigo,
    nombre,
    precioCompra,
    precioVenta,
    stock,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Producto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('precio_compra')) {
      context.handle(
        _precioCompraMeta,
        precioCompra.isAcceptableOrUnknown(
          data['precio_compra']!,
          _precioCompraMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioCompraMeta);
    }
    if (data.containsKey('precio_venta')) {
      context.handle(
        _precioVentaMeta,
        precioVenta.isAcceptableOrUnknown(
          data['precio_venta']!,
          _precioVentaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioVentaMeta);
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    } else if (isInserting) {
      context.missing(_stockMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Producto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Producto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      precioCompra: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_compra'],
      )!,
      precioVenta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_venta'],
      )!,
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock'],
      )!,
    );
  }

  @override
  $ProductosTable createAlias(String alias) {
    return $ProductosTable(attachedDatabase, alias);
  }
}

class Producto extends DataClass implements Insertable<Producto> {
  final int id;
  final String codigo;
  final String nombre;
  final double precioCompra;
  final double precioVenta;
  final int stock;
  const Producto({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.precioCompra,
    required this.precioVenta,
    required this.stock,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codigo'] = Variable<String>(codigo);
    map['nombre'] = Variable<String>(nombre);
    map['precio_compra'] = Variable<double>(precioCompra);
    map['precio_venta'] = Variable<double>(precioVenta);
    map['stock'] = Variable<int>(stock);
    return map;
  }

  ProductosCompanion toCompanion(bool nullToAbsent) {
    return ProductosCompanion(
      id: Value(id),
      codigo: Value(codigo),
      nombre: Value(nombre),
      precioCompra: Value(precioCompra),
      precioVenta: Value(precioVenta),
      stock: Value(stock),
    );
  }

  factory Producto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Producto(
      id: serializer.fromJson<int>(json['id']),
      codigo: serializer.fromJson<String>(json['codigo']),
      nombre: serializer.fromJson<String>(json['nombre']),
      precioCompra: serializer.fromJson<double>(json['precioCompra']),
      precioVenta: serializer.fromJson<double>(json['precioVenta']),
      stock: serializer.fromJson<int>(json['stock']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigo': serializer.toJson<String>(codigo),
      'nombre': serializer.toJson<String>(nombre),
      'precioCompra': serializer.toJson<double>(precioCompra),
      'precioVenta': serializer.toJson<double>(precioVenta),
      'stock': serializer.toJson<int>(stock),
    };
  }

  Producto copyWith({
    int? id,
    String? codigo,
    String? nombre,
    double? precioCompra,
    double? precioVenta,
    int? stock,
  }) => Producto(
    id: id ?? this.id,
    codigo: codigo ?? this.codigo,
    nombre: nombre ?? this.nombre,
    precioCompra: precioCompra ?? this.precioCompra,
    precioVenta: precioVenta ?? this.precioVenta,
    stock: stock ?? this.stock,
  );
  Producto copyWithCompanion(ProductosCompanion data) {
    return Producto(
      id: data.id.present ? data.id.value : this.id,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      precioCompra: data.precioCompra.present
          ? data.precioCompra.value
          : this.precioCompra,
      precioVenta: data.precioVenta.present
          ? data.precioVenta.value
          : this.precioVenta,
      stock: data.stock.present ? data.stock.value : this.stock,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Producto(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('precioCompra: $precioCompra, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('stock: $stock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, codigo, nombre, precioCompra, precioVenta, stock);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Producto &&
          other.id == this.id &&
          other.codigo == this.codigo &&
          other.nombre == this.nombre &&
          other.precioCompra == this.precioCompra &&
          other.precioVenta == this.precioVenta &&
          other.stock == this.stock);
}

class ProductosCompanion extends UpdateCompanion<Producto> {
  final Value<int> id;
  final Value<String> codigo;
  final Value<String> nombre;
  final Value<double> precioCompra;
  final Value<double> precioVenta;
  final Value<int> stock;
  const ProductosCompanion({
    this.id = const Value.absent(),
    this.codigo = const Value.absent(),
    this.nombre = const Value.absent(),
    this.precioCompra = const Value.absent(),
    this.precioVenta = const Value.absent(),
    this.stock = const Value.absent(),
  });
  ProductosCompanion.insert({
    this.id = const Value.absent(),
    required String codigo,
    required String nombre,
    required double precioCompra,
    required double precioVenta,
    required int stock,
  }) : codigo = Value(codigo),
       nombre = Value(nombre),
       precioCompra = Value(precioCompra),
       precioVenta = Value(precioVenta),
       stock = Value(stock);
  static Insertable<Producto> custom({
    Expression<int>? id,
    Expression<String>? codigo,
    Expression<String>? nombre,
    Expression<double>? precioCompra,
    Expression<double>? precioVenta,
    Expression<int>? stock,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigo != null) 'codigo': codigo,
      if (nombre != null) 'nombre': nombre,
      if (precioCompra != null) 'precio_compra': precioCompra,
      if (precioVenta != null) 'precio_venta': precioVenta,
      if (stock != null) 'stock': stock,
    });
  }

  ProductosCompanion copyWith({
    Value<int>? id,
    Value<String>? codigo,
    Value<String>? nombre,
    Value<double>? precioCompra,
    Value<double>? precioVenta,
    Value<int>? stock,
  }) {
    return ProductosCompanion(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      precioCompra: precioCompra ?? this.precioCompra,
      precioVenta: precioVenta ?? this.precioVenta,
      stock: stock ?? this.stock,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (precioCompra.present) {
      map['precio_compra'] = Variable<double>(precioCompra.value);
    }
    if (precioVenta.present) {
      map['precio_venta'] = Variable<double>(precioVenta.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductosCompanion(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('precioCompra: $precioCompra, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('stock: $stock')
          ..write(')'))
        .toString();
  }
}

class $VentasTable extends Ventas with TableInfo<$VentasTable, Venta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    check: () => ComparableExpr(total).isBiggerOrEqual(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, fecha, total];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ventas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Venta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Venta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Venta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
    );
  }

  @override
  $VentasTable createAlias(String alias) {
    return $VentasTable(attachedDatabase, alias);
  }
}

class Venta extends DataClass implements Insertable<Venta> {
  final int id;
  final DateTime fecha;
  final double total;
  const Venta({required this.id, required this.fecha, required this.total});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fecha'] = Variable<DateTime>(fecha);
    map['total'] = Variable<double>(total);
    return map;
  }

  VentasCompanion toCompanion(bool nullToAbsent) {
    return VentasCompanion(
      id: Value(id),
      fecha: Value(fecha),
      total: Value(total),
    );
  }

  factory Venta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Venta(
      id: serializer.fromJson<int>(json['id']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      total: serializer.fromJson<double>(json['total']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fecha': serializer.toJson<DateTime>(fecha),
      'total': serializer.toJson<double>(total),
    };
  }

  Venta copyWith({int? id, DateTime? fecha, double? total}) => Venta(
    id: id ?? this.id,
    fecha: fecha ?? this.fecha,
    total: total ?? this.total,
  );
  Venta copyWithCompanion(VentasCompanion data) {
    return Venta(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      total: data.total.present ? data.total.value : this.total,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Venta(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('total: $total')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fecha, total);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Venta &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.total == this.total);
}

class VentasCompanion extends UpdateCompanion<Venta> {
  final Value<int> id;
  final Value<DateTime> fecha;
  final Value<double> total;
  const VentasCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.total = const Value.absent(),
  });
  VentasCompanion.insert({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    required double total,
  }) : total = Value(total);
  static Insertable<Venta> custom({
    Expression<int>? id,
    Expression<DateTime>? fecha,
    Expression<double>? total,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (total != null) 'total': total,
    });
  }

  VentasCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? fecha,
    Value<double>? total,
  }) {
    return VentasCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      total: total ?? this.total,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VentasCompanion(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('total: $total')
          ..write(')'))
        .toString();
  }
}

class $DetallesVentaTable extends DetallesVenta
    with TableInfo<$DetallesVentaTable, DetallesVentaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetallesVentaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ventaIdMeta = const VerificationMeta(
    'ventaId',
  );
  @override
  late final GeneratedColumn<int> ventaId = GeneratedColumn<int>(
    'venta_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ventas (id)',
    ),
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<int> productoId = GeneratedColumn<int>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES productos (id)',
    ),
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
    'cantidad',
    aliasedName,
    false,
    check: () => ComparableExpr(cantidad).isBiggerThan(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioUnitarioMeta = const VerificationMeta(
    'precioUnitario',
  );
  @override
  late final GeneratedColumn<double> precioUnitario = GeneratedColumn<double>(
    'precio_unitario',
    aliasedName,
    false,
    check: () => ComparableExpr(precioUnitario).isBiggerThan(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ventaId,
    productoId,
    cantidad,
    precioUnitario,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detalles_venta';
  @override
  VerificationContext validateIntegrity(
    Insertable<DetallesVentaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('venta_id')) {
      context.handle(
        _ventaIdMeta,
        ventaId.isAcceptableOrUnknown(data['venta_id']!, _ventaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ventaIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
        _precioUnitarioMeta,
        precioUnitario.isAcceptableOrUnknown(
          data['precio_unitario']!,
          _precioUnitarioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioUnitarioMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DetallesVentaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DetallesVentaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ventaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}venta_id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}producto_id'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad'],
      )!,
      precioUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_unitario'],
      )!,
    );
  }

  @override
  $DetallesVentaTable createAlias(String alias) {
    return $DetallesVentaTable(attachedDatabase, alias);
  }
}

class DetallesVentaData extends DataClass
    implements Insertable<DetallesVentaData> {
  final int id;
  final int ventaId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  const DetallesVentaData({
    required this.id,
    required this.ventaId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['venta_id'] = Variable<int>(ventaId);
    map['producto_id'] = Variable<int>(productoId);
    map['cantidad'] = Variable<int>(cantidad);
    map['precio_unitario'] = Variable<double>(precioUnitario);
    return map;
  }

  DetallesVentaCompanion toCompanion(bool nullToAbsent) {
    return DetallesVentaCompanion(
      id: Value(id),
      ventaId: Value(ventaId),
      productoId: Value(productoId),
      cantidad: Value(cantidad),
      precioUnitario: Value(precioUnitario),
    );
  }

  factory DetallesVentaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DetallesVentaData(
      id: serializer.fromJson<int>(json['id']),
      ventaId: serializer.fromJson<int>(json['ventaId']),
      productoId: serializer.fromJson<int>(json['productoId']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      precioUnitario: serializer.fromJson<double>(json['precioUnitario']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ventaId': serializer.toJson<int>(ventaId),
      'productoId': serializer.toJson<int>(productoId),
      'cantidad': serializer.toJson<int>(cantidad),
      'precioUnitario': serializer.toJson<double>(precioUnitario),
    };
  }

  DetallesVentaData copyWith({
    int? id,
    int? ventaId,
    int? productoId,
    int? cantidad,
    double? precioUnitario,
  }) => DetallesVentaData(
    id: id ?? this.id,
    ventaId: ventaId ?? this.ventaId,
    productoId: productoId ?? this.productoId,
    cantidad: cantidad ?? this.cantidad,
    precioUnitario: precioUnitario ?? this.precioUnitario,
  );
  DetallesVentaData copyWithCompanion(DetallesVentaCompanion data) {
    return DetallesVentaData(
      id: data.id.present ? data.id.value : this.id,
      ventaId: data.ventaId.present ? data.ventaId.value : this.ventaId,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DetallesVentaData(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ventaId, productoId, cantidad, precioUnitario);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DetallesVentaData &&
          other.id == this.id &&
          other.ventaId == this.ventaId &&
          other.productoId == this.productoId &&
          other.cantidad == this.cantidad &&
          other.precioUnitario == this.precioUnitario);
}

class DetallesVentaCompanion extends UpdateCompanion<DetallesVentaData> {
  final Value<int> id;
  final Value<int> ventaId;
  final Value<int> productoId;
  final Value<int> cantidad;
  final Value<double> precioUnitario;
  const DetallesVentaCompanion({
    this.id = const Value.absent(),
    this.ventaId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precioUnitario = const Value.absent(),
  });
  DetallesVentaCompanion.insert({
    this.id = const Value.absent(),
    required int ventaId,
    required int productoId,
    required int cantidad,
    required double precioUnitario,
  }) : ventaId = Value(ventaId),
       productoId = Value(productoId),
       cantidad = Value(cantidad),
       precioUnitario = Value(precioUnitario);
  static Insertable<DetallesVentaData> custom({
    Expression<int>? id,
    Expression<int>? ventaId,
    Expression<int>? productoId,
    Expression<int>? cantidad,
    Expression<double>? precioUnitario,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ventaId != null) 'venta_id': ventaId,
      if (productoId != null) 'producto_id': productoId,
      if (cantidad != null) 'cantidad': cantidad,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
    });
  }

  DetallesVentaCompanion copyWith({
    Value<int>? id,
    Value<int>? ventaId,
    Value<int>? productoId,
    Value<int>? cantidad,
    Value<double>? precioUnitario,
  }) {
    return DetallesVentaCompanion(
      id: id ?? this.id,
      ventaId: ventaId ?? this.ventaId,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ventaId.present) {
      map['venta_id'] = Variable<int>(ventaId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<int>(productoId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<double>(precioUnitario.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetallesVentaCompanion(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario')
          ..write(')'))
        .toString();
  }
}

class $ProveedoresTable extends Proveedores
    with TableInfo<$ProveedoresTable, Proveedore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProveedoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactoMeta = const VerificationMeta(
    'contacto',
  );
  @override
  late final GeneratedColumn<String> contacto = GeneratedColumn<String>(
    'contacto',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 0,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nombre, contacto];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'proveedores';
  @override
  VerificationContext validateIntegrity(
    Insertable<Proveedore> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('contacto')) {
      context.handle(
        _contactoMeta,
        contacto.isAcceptableOrUnknown(data['contacto']!, _contactoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Proveedore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Proveedore(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      contacto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contacto'],
      ),
    );
  }

  @override
  $ProveedoresTable createAlias(String alias) {
    return $ProveedoresTable(attachedDatabase, alias);
  }
}

class Proveedore extends DataClass implements Insertable<Proveedore> {
  final int id;
  final String nombre;
  final String? contacto;
  const Proveedore({required this.id, required this.nombre, this.contacto});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || contacto != null) {
      map['contacto'] = Variable<String>(contacto);
    }
    return map;
  }

  ProveedoresCompanion toCompanion(bool nullToAbsent) {
    return ProveedoresCompanion(
      id: Value(id),
      nombre: Value(nombre),
      contacto: contacto == null && nullToAbsent
          ? const Value.absent()
          : Value(contacto),
    );
  }

  factory Proveedore.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Proveedore(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      contacto: serializer.fromJson<String?>(json['contacto']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'contacto': serializer.toJson<String?>(contacto),
    };
  }

  Proveedore copyWith({
    int? id,
    String? nombre,
    Value<String?> contacto = const Value.absent(),
  }) => Proveedore(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    contacto: contacto.present ? contacto.value : this.contacto,
  );
  Proveedore copyWithCompanion(ProveedoresCompanion data) {
    return Proveedore(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      contacto: data.contacto.present ? data.contacto.value : this.contacto,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Proveedore(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('contacto: $contacto')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, contacto);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Proveedore &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.contacto == this.contacto);
}

class ProveedoresCompanion extends UpdateCompanion<Proveedore> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String?> contacto;
  const ProveedoresCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.contacto = const Value.absent(),
  });
  ProveedoresCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.contacto = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<Proveedore> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? contacto,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (contacto != null) 'contacto': contacto,
    });
  }

  ProveedoresCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String?>? contacto,
  }) {
    return ProveedoresCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      contacto: contacto ?? this.contacto,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (contacto.present) {
      map['contacto'] = Variable<String>(contacto.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProveedoresCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('contacto: $contacto')
          ..write(')'))
        .toString();
  }
}

class $ComprasTable extends Compras with TableInfo<$ComprasTable, Compra> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComprasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _proveedorIdMeta = const VerificationMeta(
    'proveedorId',
  );
  @override
  late final GeneratedColumn<int> proveedorId = GeneratedColumn<int>(
    'proveedor_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES proveedores (id)',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    check: () => ComparableExpr(total).isBiggerOrEqual(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, proveedorId, fecha, total];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compras';
  @override
  VerificationContext validateIntegrity(
    Insertable<Compra> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('proveedor_id')) {
      context.handle(
        _proveedorIdMeta,
        proveedorId.isAcceptableOrUnknown(
          data['proveedor_id']!,
          _proveedorIdMeta,
        ),
      );
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Compra map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Compra(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      proveedorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}proveedor_id'],
      ),
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
    );
  }

  @override
  $ComprasTable createAlias(String alias) {
    return $ComprasTable(attachedDatabase, alias);
  }
}

class Compra extends DataClass implements Insertable<Compra> {
  final int id;
  final int? proveedorId;
  final DateTime fecha;
  final double total;
  const Compra({
    required this.id,
    this.proveedorId,
    required this.fecha,
    required this.total,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || proveedorId != null) {
      map['proveedor_id'] = Variable<int>(proveedorId);
    }
    map['fecha'] = Variable<DateTime>(fecha);
    map['total'] = Variable<double>(total);
    return map;
  }

  ComprasCompanion toCompanion(bool nullToAbsent) {
    return ComprasCompanion(
      id: Value(id),
      proveedorId: proveedorId == null && nullToAbsent
          ? const Value.absent()
          : Value(proveedorId),
      fecha: Value(fecha),
      total: Value(total),
    );
  }

  factory Compra.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Compra(
      id: serializer.fromJson<int>(json['id']),
      proveedorId: serializer.fromJson<int?>(json['proveedorId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      total: serializer.fromJson<double>(json['total']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'proveedorId': serializer.toJson<int?>(proveedorId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'total': serializer.toJson<double>(total),
    };
  }

  Compra copyWith({
    int? id,
    Value<int?> proveedorId = const Value.absent(),
    DateTime? fecha,
    double? total,
  }) => Compra(
    id: id ?? this.id,
    proveedorId: proveedorId.present ? proveedorId.value : this.proveedorId,
    fecha: fecha ?? this.fecha,
    total: total ?? this.total,
  );
  Compra copyWithCompanion(ComprasCompanion data) {
    return Compra(
      id: data.id.present ? data.id.value : this.id,
      proveedorId: data.proveedorId.present
          ? data.proveedorId.value
          : this.proveedorId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      total: data.total.present ? data.total.value : this.total,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Compra(')
          ..write('id: $id, ')
          ..write('proveedorId: $proveedorId, ')
          ..write('fecha: $fecha, ')
          ..write('total: $total')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, proveedorId, fecha, total);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Compra &&
          other.id == this.id &&
          other.proveedorId == this.proveedorId &&
          other.fecha == this.fecha &&
          other.total == this.total);
}

class ComprasCompanion extends UpdateCompanion<Compra> {
  final Value<int> id;
  final Value<int?> proveedorId;
  final Value<DateTime> fecha;
  final Value<double> total;
  const ComprasCompanion({
    this.id = const Value.absent(),
    this.proveedorId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.total = const Value.absent(),
  });
  ComprasCompanion.insert({
    this.id = const Value.absent(),
    this.proveedorId = const Value.absent(),
    this.fecha = const Value.absent(),
    required double total,
  }) : total = Value(total);
  static Insertable<Compra> custom({
    Expression<int>? id,
    Expression<int>? proveedorId,
    Expression<DateTime>? fecha,
    Expression<double>? total,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (proveedorId != null) 'proveedor_id': proveedorId,
      if (fecha != null) 'fecha': fecha,
      if (total != null) 'total': total,
    });
  }

  ComprasCompanion copyWith({
    Value<int>? id,
    Value<int?>? proveedorId,
    Value<DateTime>? fecha,
    Value<double>? total,
  }) {
    return ComprasCompanion(
      id: id ?? this.id,
      proveedorId: proveedorId ?? this.proveedorId,
      fecha: fecha ?? this.fecha,
      total: total ?? this.total,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (proveedorId.present) {
      map['proveedor_id'] = Variable<int>(proveedorId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComprasCompanion(')
          ..write('id: $id, ')
          ..write('proveedorId: $proveedorId, ')
          ..write('fecha: $fecha, ')
          ..write('total: $total')
          ..write(')'))
        .toString();
  }
}

class $DetallesCompraTable extends DetallesCompra
    with TableInfo<$DetallesCompraTable, DetallesCompraData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetallesCompraTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _compraIdMeta = const VerificationMeta(
    'compraId',
  );
  @override
  late final GeneratedColumn<int> compraId = GeneratedColumn<int>(
    'compra_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES compras (id)',
    ),
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<int> productoId = GeneratedColumn<int>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES productos (id)',
    ),
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
    'cantidad',
    aliasedName,
    false,
    check: () => ComparableExpr(cantidad).isBiggerThan(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioUnitarioMeta = const VerificationMeta(
    'precioUnitario',
  );
  @override
  late final GeneratedColumn<double> precioUnitario = GeneratedColumn<double>(
    'precio_unitario',
    aliasedName,
    false,
    check: () => ComparableExpr(precioUnitario).isBiggerThan(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    compraId,
    productoId,
    cantidad,
    precioUnitario,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detalles_compra';
  @override
  VerificationContext validateIntegrity(
    Insertable<DetallesCompraData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('compra_id')) {
      context.handle(
        _compraIdMeta,
        compraId.isAcceptableOrUnknown(data['compra_id']!, _compraIdMeta),
      );
    } else if (isInserting) {
      context.missing(_compraIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
        _precioUnitarioMeta,
        precioUnitario.isAcceptableOrUnknown(
          data['precio_unitario']!,
          _precioUnitarioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioUnitarioMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DetallesCompraData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DetallesCompraData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      compraId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}compra_id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}producto_id'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad'],
      )!,
      precioUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_unitario'],
      )!,
    );
  }

  @override
  $DetallesCompraTable createAlias(String alias) {
    return $DetallesCompraTable(attachedDatabase, alias);
  }
}

class DetallesCompraData extends DataClass
    implements Insertable<DetallesCompraData> {
  final int id;
  final int compraId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  const DetallesCompraData({
    required this.id,
    required this.compraId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['compra_id'] = Variable<int>(compraId);
    map['producto_id'] = Variable<int>(productoId);
    map['cantidad'] = Variable<int>(cantidad);
    map['precio_unitario'] = Variable<double>(precioUnitario);
    return map;
  }

  DetallesCompraCompanion toCompanion(bool nullToAbsent) {
    return DetallesCompraCompanion(
      id: Value(id),
      compraId: Value(compraId),
      productoId: Value(productoId),
      cantidad: Value(cantidad),
      precioUnitario: Value(precioUnitario),
    );
  }

  factory DetallesCompraData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DetallesCompraData(
      id: serializer.fromJson<int>(json['id']),
      compraId: serializer.fromJson<int>(json['compraId']),
      productoId: serializer.fromJson<int>(json['productoId']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      precioUnitario: serializer.fromJson<double>(json['precioUnitario']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'compraId': serializer.toJson<int>(compraId),
      'productoId': serializer.toJson<int>(productoId),
      'cantidad': serializer.toJson<int>(cantidad),
      'precioUnitario': serializer.toJson<double>(precioUnitario),
    };
  }

  DetallesCompraData copyWith({
    int? id,
    int? compraId,
    int? productoId,
    int? cantidad,
    double? precioUnitario,
  }) => DetallesCompraData(
    id: id ?? this.id,
    compraId: compraId ?? this.compraId,
    productoId: productoId ?? this.productoId,
    cantidad: cantidad ?? this.cantidad,
    precioUnitario: precioUnitario ?? this.precioUnitario,
  );
  DetallesCompraData copyWithCompanion(DetallesCompraCompanion data) {
    return DetallesCompraData(
      id: data.id.present ? data.id.value : this.id,
      compraId: data.compraId.present ? data.compraId.value : this.compraId,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DetallesCompraData(')
          ..write('id: $id, ')
          ..write('compraId: $compraId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, compraId, productoId, cantidad, precioUnitario);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DetallesCompraData &&
          other.id == this.id &&
          other.compraId == this.compraId &&
          other.productoId == this.productoId &&
          other.cantidad == this.cantidad &&
          other.precioUnitario == this.precioUnitario);
}

class DetallesCompraCompanion extends UpdateCompanion<DetallesCompraData> {
  final Value<int> id;
  final Value<int> compraId;
  final Value<int> productoId;
  final Value<int> cantidad;
  final Value<double> precioUnitario;
  const DetallesCompraCompanion({
    this.id = const Value.absent(),
    this.compraId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precioUnitario = const Value.absent(),
  });
  DetallesCompraCompanion.insert({
    this.id = const Value.absent(),
    required int compraId,
    required int productoId,
    required int cantidad,
    required double precioUnitario,
  }) : compraId = Value(compraId),
       productoId = Value(productoId),
       cantidad = Value(cantidad),
       precioUnitario = Value(precioUnitario);
  static Insertable<DetallesCompraData> custom({
    Expression<int>? id,
    Expression<int>? compraId,
    Expression<int>? productoId,
    Expression<int>? cantidad,
    Expression<double>? precioUnitario,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (compraId != null) 'compra_id': compraId,
      if (productoId != null) 'producto_id': productoId,
      if (cantidad != null) 'cantidad': cantidad,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
    });
  }

  DetallesCompraCompanion copyWith({
    Value<int>? id,
    Value<int>? compraId,
    Value<int>? productoId,
    Value<int>? cantidad,
    Value<double>? precioUnitario,
  }) {
    return DetallesCompraCompanion(
      id: id ?? this.id,
      compraId: compraId ?? this.compraId,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (compraId.present) {
      map['compra_id'] = Variable<int>(compraId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<int>(productoId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<double>(precioUnitario.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetallesCompraCompanion(')
          ..write('id: $id, ')
          ..write('compraId: $compraId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductosTable productos = $ProductosTable(this);
  late final $VentasTable ventas = $VentasTable(this);
  late final $DetallesVentaTable detallesVenta = $DetallesVentaTable(this);
  late final $ProveedoresTable proveedores = $ProveedoresTable(this);
  late final $ComprasTable compras = $ComprasTable(this);
  late final $DetallesCompraTable detallesCompra = $DetallesCompraTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    productos,
    ventas,
    detallesVenta,
    proveedores,
    compras,
    detallesCompra,
  ];
}

typedef $$ProductosTableCreateCompanionBuilder =
    ProductosCompanion Function({
      Value<int> id,
      required String codigo,
      required String nombre,
      required double precioCompra,
      required double precioVenta,
      required int stock,
    });
typedef $$ProductosTableUpdateCompanionBuilder =
    ProductosCompanion Function({
      Value<int> id,
      Value<String> codigo,
      Value<String> nombre,
      Value<double> precioCompra,
      Value<double> precioVenta,
      Value<int> stock,
    });

final class $$ProductosTableReferences
    extends BaseReferences<_$AppDatabase, $ProductosTable, Producto> {
  $$ProductosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DetallesVentaTable, List<DetallesVentaData>>
  _detallesVentaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.detallesVenta,
    aliasName: $_aliasNameGenerator(
      db.productos.id,
      db.detallesVenta.productoId,
    ),
  );

  $$DetallesVentaTableProcessedTableManager get detallesVentaRefs {
    final manager = $$DetallesVentaTableTableManager(
      $_db,
      $_db.detallesVenta,
    ).filter((f) => f.productoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_detallesVentaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DetallesCompraTable, List<DetallesCompraData>>
  _detallesCompraRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.detallesCompra,
    aliasName: $_aliasNameGenerator(
      db.productos.id,
      db.detallesCompra.productoId,
    ),
  );

  $$DetallesCompraTableProcessedTableManager get detallesCompraRefs {
    final manager = $$DetallesCompraTableTableManager(
      $_db,
      $_db.detallesCompra,
    ).filter((f) => f.productoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_detallesCompraRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductosTableFilterComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioCompra => $composableBuilder(
    column: $table.precioCompra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> detallesVentaRefs(
    Expression<bool> Function($$DetallesVentaTableFilterComposer f) f,
  ) {
    final $$DetallesVentaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detallesVenta,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetallesVentaTableFilterComposer(
            $db: $db,
            $table: $db.detallesVenta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> detallesCompraRefs(
    Expression<bool> Function($$DetallesCompraTableFilterComposer f) f,
  ) {
    final $$DetallesCompraTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detallesCompra,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetallesCompraTableFilterComposer(
            $db: $db,
            $table: $db.detallesCompra,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductosTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioCompra => $composableBuilder(
    column: $table.precioCompra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<double> get precioCompra => $composableBuilder(
    column: $table.precioCompra,
    builder: (column) => column,
  );

  GeneratedColumn<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  Expression<T> detallesVentaRefs<T extends Object>(
    Expression<T> Function($$DetallesVentaTableAnnotationComposer a) f,
  ) {
    final $$DetallesVentaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detallesVenta,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetallesVentaTableAnnotationComposer(
            $db: $db,
            $table: $db.detallesVenta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> detallesCompraRefs<T extends Object>(
    Expression<T> Function($$DetallesCompraTableAnnotationComposer a) f,
  ) {
    final $$DetallesCompraTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detallesCompra,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetallesCompraTableAnnotationComposer(
            $db: $db,
            $table: $db.detallesCompra,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductosTable,
          Producto,
          $$ProductosTableFilterComposer,
          $$ProductosTableOrderingComposer,
          $$ProductosTableAnnotationComposer,
          $$ProductosTableCreateCompanionBuilder,
          $$ProductosTableUpdateCompanionBuilder,
          (Producto, $$ProductosTableReferences),
          Producto,
          PrefetchHooks Function({
            bool detallesVentaRefs,
            bool detallesCompraRefs,
          })
        > {
  $$ProductosTableTableManager(_$AppDatabase db, $ProductosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<double> precioCompra = const Value.absent(),
                Value<double> precioVenta = const Value.absent(),
                Value<int> stock = const Value.absent(),
              }) => ProductosCompanion(
                id: id,
                codigo: codigo,
                nombre: nombre,
                precioCompra: precioCompra,
                precioVenta: precioVenta,
                stock: stock,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codigo,
                required String nombre,
                required double precioCompra,
                required double precioVenta,
                required int stock,
              }) => ProductosCompanion.insert(
                id: id,
                codigo: codigo,
                nombre: nombre,
                precioCompra: precioCompra,
                precioVenta: precioVenta,
                stock: stock,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({detallesVentaRefs = false, detallesCompraRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (detallesVentaRefs) db.detallesVenta,
                    if (detallesCompraRefs) db.detallesCompra,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (detallesVentaRefs)
                        await $_getPrefetchedData<
                          Producto,
                          $ProductosTable,
                          DetallesVentaData
                        >(
                          currentTable: table,
                          referencedTable: $$ProductosTableReferences
                              ._detallesVentaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductosTableReferences(
                                db,
                                table,
                                p0,
                              ).detallesVentaRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (detallesCompraRefs)
                        await $_getPrefetchedData<
                          Producto,
                          $ProductosTable,
                          DetallesCompraData
                        >(
                          currentTable: table,
                          referencedTable: $$ProductosTableReferences
                              ._detallesCompraRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductosTableReferences(
                                db,
                                table,
                                p0,
                              ).detallesCompraRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductosTable,
      Producto,
      $$ProductosTableFilterComposer,
      $$ProductosTableOrderingComposer,
      $$ProductosTableAnnotationComposer,
      $$ProductosTableCreateCompanionBuilder,
      $$ProductosTableUpdateCompanionBuilder,
      (Producto, $$ProductosTableReferences),
      Producto,
      PrefetchHooks Function({bool detallesVentaRefs, bool detallesCompraRefs})
    >;
typedef $$VentasTableCreateCompanionBuilder =
    VentasCompanion Function({
      Value<int> id,
      Value<DateTime> fecha,
      required double total,
    });
typedef $$VentasTableUpdateCompanionBuilder =
    VentasCompanion Function({
      Value<int> id,
      Value<DateTime> fecha,
      Value<double> total,
    });

final class $$VentasTableReferences
    extends BaseReferences<_$AppDatabase, $VentasTable, Venta> {
  $$VentasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DetallesVentaTable, List<DetallesVentaData>>
  _detallesVentaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.detallesVenta,
    aliasName: $_aliasNameGenerator(db.ventas.id, db.detallesVenta.ventaId),
  );

  $$DetallesVentaTableProcessedTableManager get detallesVentaRefs {
    final manager = $$DetallesVentaTableTableManager(
      $_db,
      $_db.detallesVenta,
    ).filter((f) => f.ventaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_detallesVentaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VentasTableFilterComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> detallesVentaRefs(
    Expression<bool> Function($$DetallesVentaTableFilterComposer f) f,
  ) {
    final $$DetallesVentaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detallesVenta,
      getReferencedColumn: (t) => t.ventaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetallesVentaTableFilterComposer(
            $db: $db,
            $table: $db.detallesVenta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VentasTableOrderingComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VentasTableAnnotationComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  Expression<T> detallesVentaRefs<T extends Object>(
    Expression<T> Function($$DetallesVentaTableAnnotationComposer a) f,
  ) {
    final $$DetallesVentaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detallesVenta,
      getReferencedColumn: (t) => t.ventaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetallesVentaTableAnnotationComposer(
            $db: $db,
            $table: $db.detallesVenta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VentasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VentasTable,
          Venta,
          $$VentasTableFilterComposer,
          $$VentasTableOrderingComposer,
          $$VentasTableAnnotationComposer,
          $$VentasTableCreateCompanionBuilder,
          $$VentasTableUpdateCompanionBuilder,
          (Venta, $$VentasTableReferences),
          Venta,
          PrefetchHooks Function({bool detallesVentaRefs})
        > {
  $$VentasTableTableManager(_$AppDatabase db, $VentasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<double> total = const Value.absent(),
              }) => VentasCompanion(id: id, fecha: fecha, total: total),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                required double total,
              }) => VentasCompanion.insert(id: id, fecha: fecha, total: total),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$VentasTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({detallesVentaRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (detallesVentaRefs) db.detallesVenta,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (detallesVentaRefs)
                    await $_getPrefetchedData<
                      Venta,
                      $VentasTable,
                      DetallesVentaData
                    >(
                      currentTable: table,
                      referencedTable: $$VentasTableReferences
                          ._detallesVentaRefsTable(db),
                      managerFromTypedResult: (p0) => $$VentasTableReferences(
                        db,
                        table,
                        p0,
                      ).detallesVentaRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.ventaId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VentasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VentasTable,
      Venta,
      $$VentasTableFilterComposer,
      $$VentasTableOrderingComposer,
      $$VentasTableAnnotationComposer,
      $$VentasTableCreateCompanionBuilder,
      $$VentasTableUpdateCompanionBuilder,
      (Venta, $$VentasTableReferences),
      Venta,
      PrefetchHooks Function({bool detallesVentaRefs})
    >;
typedef $$DetallesVentaTableCreateCompanionBuilder =
    DetallesVentaCompanion Function({
      Value<int> id,
      required int ventaId,
      required int productoId,
      required int cantidad,
      required double precioUnitario,
    });
typedef $$DetallesVentaTableUpdateCompanionBuilder =
    DetallesVentaCompanion Function({
      Value<int> id,
      Value<int> ventaId,
      Value<int> productoId,
      Value<int> cantidad,
      Value<double> precioUnitario,
    });

final class $$DetallesVentaTableReferences
    extends
        BaseReferences<_$AppDatabase, $DetallesVentaTable, DetallesVentaData> {
  $$DetallesVentaTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VentasTable _ventaIdTable(_$AppDatabase db) => db.ventas.createAlias(
    $_aliasNameGenerator(db.detallesVenta.ventaId, db.ventas.id),
  );

  $$VentasTableProcessedTableManager get ventaId {
    final $_column = $_itemColumn<int>('venta_id')!;

    final manager = $$VentasTableTableManager(
      $_db,
      $_db.ventas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ventaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductosTable _productoIdTable(_$AppDatabase db) =>
      db.productos.createAlias(
        $_aliasNameGenerator(db.detallesVenta.productoId, db.productos.id),
      );

  $$ProductosTableProcessedTableManager get productoId {
    final $_column = $_itemColumn<int>('producto_id')!;

    final manager = $$ProductosTableTableManager(
      $_db,
      $_db.productos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DetallesVentaTableFilterComposer
    extends Composer<_$AppDatabase, $DetallesVentaTable> {
  $$DetallesVentaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnFilters(column),
  );

  $$VentasTableFilterComposer get ventaId {
    final $$VentasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableFilterComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableFilterComposer get productoId {
    final $$ProductosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableFilterComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetallesVentaTableOrderingComposer
    extends Composer<_$AppDatabase, $DetallesVentaTable> {
  $$DetallesVentaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  $$VentasTableOrderingComposer get ventaId {
    final $$VentasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableOrderingComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableOrderingComposer get productoId {
    final $$ProductosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableOrderingComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetallesVentaTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetallesVentaTable> {
  $$DetallesVentaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => column,
  );

  $$VentasTableAnnotationComposer get ventaId {
    final $$VentasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableAnnotationComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableAnnotationComposer get productoId {
    final $$ProductosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableAnnotationComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetallesVentaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DetallesVentaTable,
          DetallesVentaData,
          $$DetallesVentaTableFilterComposer,
          $$DetallesVentaTableOrderingComposer,
          $$DetallesVentaTableAnnotationComposer,
          $$DetallesVentaTableCreateCompanionBuilder,
          $$DetallesVentaTableUpdateCompanionBuilder,
          (DetallesVentaData, $$DetallesVentaTableReferences),
          DetallesVentaData,
          PrefetchHooks Function({bool ventaId, bool productoId})
        > {
  $$DetallesVentaTableTableManager(_$AppDatabase db, $DetallesVentaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetallesVentaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetallesVentaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetallesVentaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ventaId = const Value.absent(),
                Value<int> productoId = const Value.absent(),
                Value<int> cantidad = const Value.absent(),
                Value<double> precioUnitario = const Value.absent(),
              }) => DetallesVentaCompanion(
                id: id,
                ventaId: ventaId,
                productoId: productoId,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ventaId,
                required int productoId,
                required int cantidad,
                required double precioUnitario,
              }) => DetallesVentaCompanion.insert(
                id: id,
                ventaId: ventaId,
                productoId: productoId,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DetallesVentaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ventaId = false, productoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ventaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ventaId,
                                referencedTable: $$DetallesVentaTableReferences
                                    ._ventaIdTable(db),
                                referencedColumn: $$DetallesVentaTableReferences
                                    ._ventaIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (productoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productoId,
                                referencedTable: $$DetallesVentaTableReferences
                                    ._productoIdTable(db),
                                referencedColumn: $$DetallesVentaTableReferences
                                    ._productoIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DetallesVentaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DetallesVentaTable,
      DetallesVentaData,
      $$DetallesVentaTableFilterComposer,
      $$DetallesVentaTableOrderingComposer,
      $$DetallesVentaTableAnnotationComposer,
      $$DetallesVentaTableCreateCompanionBuilder,
      $$DetallesVentaTableUpdateCompanionBuilder,
      (DetallesVentaData, $$DetallesVentaTableReferences),
      DetallesVentaData,
      PrefetchHooks Function({bool ventaId, bool productoId})
    >;
typedef $$ProveedoresTableCreateCompanionBuilder =
    ProveedoresCompanion Function({
      Value<int> id,
      required String nombre,
      Value<String?> contacto,
    });
typedef $$ProveedoresTableUpdateCompanionBuilder =
    ProveedoresCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<String?> contacto,
    });

final class $$ProveedoresTableReferences
    extends BaseReferences<_$AppDatabase, $ProveedoresTable, Proveedore> {
  $$ProveedoresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ComprasTable, List<Compra>> _comprasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.compras,
    aliasName: $_aliasNameGenerator(db.proveedores.id, db.compras.proveedorId),
  );

  $$ComprasTableProcessedTableManager get comprasRefs {
    final manager = $$ComprasTableTableManager(
      $_db,
      $_db.compras,
    ).filter((f) => f.proveedorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_comprasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProveedoresTableFilterComposer
    extends Composer<_$AppDatabase, $ProveedoresTable> {
  $$ProveedoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contacto => $composableBuilder(
    column: $table.contacto,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> comprasRefs(
    Expression<bool> Function($$ComprasTableFilterComposer f) f,
  ) {
    final $$ComprasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.proveedorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableFilterComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProveedoresTableOrderingComposer
    extends Composer<_$AppDatabase, $ProveedoresTable> {
  $$ProveedoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contacto => $composableBuilder(
    column: $table.contacto,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProveedoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProveedoresTable> {
  $$ProveedoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get contacto =>
      $composableBuilder(column: $table.contacto, builder: (column) => column);

  Expression<T> comprasRefs<T extends Object>(
    Expression<T> Function($$ComprasTableAnnotationComposer a) f,
  ) {
    final $$ComprasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.proveedorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableAnnotationComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProveedoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProveedoresTable,
          Proveedore,
          $$ProveedoresTableFilterComposer,
          $$ProveedoresTableOrderingComposer,
          $$ProveedoresTableAnnotationComposer,
          $$ProveedoresTableCreateCompanionBuilder,
          $$ProveedoresTableUpdateCompanionBuilder,
          (Proveedore, $$ProveedoresTableReferences),
          Proveedore,
          PrefetchHooks Function({bool comprasRefs})
        > {
  $$ProveedoresTableTableManager(_$AppDatabase db, $ProveedoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProveedoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProveedoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProveedoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> contacto = const Value.absent(),
              }) => ProveedoresCompanion(
                id: id,
                nombre: nombre,
                contacto: contacto,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                Value<String?> contacto = const Value.absent(),
              }) => ProveedoresCompanion.insert(
                id: id,
                nombre: nombre,
                contacto: contacto,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProveedoresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({comprasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (comprasRefs) db.compras],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (comprasRefs)
                    await $_getPrefetchedData<
                      Proveedore,
                      $ProveedoresTable,
                      Compra
                    >(
                      currentTable: table,
                      referencedTable: $$ProveedoresTableReferences
                          ._comprasRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ProveedoresTableReferences(
                            db,
                            table,
                            p0,
                          ).comprasRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.proveedorId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProveedoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProveedoresTable,
      Proveedore,
      $$ProveedoresTableFilterComposer,
      $$ProveedoresTableOrderingComposer,
      $$ProveedoresTableAnnotationComposer,
      $$ProveedoresTableCreateCompanionBuilder,
      $$ProveedoresTableUpdateCompanionBuilder,
      (Proveedore, $$ProveedoresTableReferences),
      Proveedore,
      PrefetchHooks Function({bool comprasRefs})
    >;
typedef $$ComprasTableCreateCompanionBuilder =
    ComprasCompanion Function({
      Value<int> id,
      Value<int?> proveedorId,
      Value<DateTime> fecha,
      required double total,
    });
typedef $$ComprasTableUpdateCompanionBuilder =
    ComprasCompanion Function({
      Value<int> id,
      Value<int?> proveedorId,
      Value<DateTime> fecha,
      Value<double> total,
    });

final class $$ComprasTableReferences
    extends BaseReferences<_$AppDatabase, $ComprasTable, Compra> {
  $$ComprasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProveedoresTable _proveedorIdTable(_$AppDatabase db) =>
      db.proveedores.createAlias(
        $_aliasNameGenerator(db.compras.proveedorId, db.proveedores.id),
      );

  $$ProveedoresTableProcessedTableManager? get proveedorId {
    final $_column = $_itemColumn<int>('proveedor_id');
    if ($_column == null) return null;
    final manager = $$ProveedoresTableTableManager(
      $_db,
      $_db.proveedores,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_proveedorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DetallesCompraTable, List<DetallesCompraData>>
  _detallesCompraRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.detallesCompra,
    aliasName: $_aliasNameGenerator(db.compras.id, db.detallesCompra.compraId),
  );

  $$DetallesCompraTableProcessedTableManager get detallesCompraRefs {
    final manager = $$DetallesCompraTableTableManager(
      $_db,
      $_db.detallesCompra,
    ).filter((f) => f.compraId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_detallesCompraRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ComprasTableFilterComposer
    extends Composer<_$AppDatabase, $ComprasTable> {
  $$ComprasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  $$ProveedoresTableFilterComposer get proveedorId {
    final $$ProveedoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.proveedorId,
      referencedTable: $db.proveedores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProveedoresTableFilterComposer(
            $db: $db,
            $table: $db.proveedores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> detallesCompraRefs(
    Expression<bool> Function($$DetallesCompraTableFilterComposer f) f,
  ) {
    final $$DetallesCompraTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detallesCompra,
      getReferencedColumn: (t) => t.compraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetallesCompraTableFilterComposer(
            $db: $db,
            $table: $db.detallesCompra,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ComprasTableOrderingComposer
    extends Composer<_$AppDatabase, $ComprasTable> {
  $$ComprasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProveedoresTableOrderingComposer get proveedorId {
    final $$ProveedoresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.proveedorId,
      referencedTable: $db.proveedores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProveedoresTableOrderingComposer(
            $db: $db,
            $table: $db.proveedores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComprasTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComprasTable> {
  $$ComprasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  $$ProveedoresTableAnnotationComposer get proveedorId {
    final $$ProveedoresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.proveedorId,
      referencedTable: $db.proveedores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProveedoresTableAnnotationComposer(
            $db: $db,
            $table: $db.proveedores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> detallesCompraRefs<T extends Object>(
    Expression<T> Function($$DetallesCompraTableAnnotationComposer a) f,
  ) {
    final $$DetallesCompraTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.detallesCompra,
      getReferencedColumn: (t) => t.compraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DetallesCompraTableAnnotationComposer(
            $db: $db,
            $table: $db.detallesCompra,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ComprasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ComprasTable,
          Compra,
          $$ComprasTableFilterComposer,
          $$ComprasTableOrderingComposer,
          $$ComprasTableAnnotationComposer,
          $$ComprasTableCreateCompanionBuilder,
          $$ComprasTableUpdateCompanionBuilder,
          (Compra, $$ComprasTableReferences),
          Compra,
          PrefetchHooks Function({bool proveedorId, bool detallesCompraRefs})
        > {
  $$ComprasTableTableManager(_$AppDatabase db, $ComprasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComprasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComprasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComprasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> proveedorId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<double> total = const Value.absent(),
              }) => ComprasCompanion(
                id: id,
                proveedorId: proveedorId,
                fecha: fecha,
                total: total,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> proveedorId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                required double total,
              }) => ComprasCompanion.insert(
                id: id,
                proveedorId: proveedorId,
                fecha: fecha,
                total: total,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ComprasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({proveedorId = false, detallesCompraRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (detallesCompraRefs) db.detallesCompra,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (proveedorId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.proveedorId,
                                    referencedTable: $$ComprasTableReferences
                                        ._proveedorIdTable(db),
                                    referencedColumn: $$ComprasTableReferences
                                        ._proveedorIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (detallesCompraRefs)
                        await $_getPrefetchedData<
                          Compra,
                          $ComprasTable,
                          DetallesCompraData
                        >(
                          currentTable: table,
                          referencedTable: $$ComprasTableReferences
                              ._detallesCompraRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ComprasTableReferences(
                                db,
                                table,
                                p0,
                              ).detallesCompraRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.compraId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ComprasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ComprasTable,
      Compra,
      $$ComprasTableFilterComposer,
      $$ComprasTableOrderingComposer,
      $$ComprasTableAnnotationComposer,
      $$ComprasTableCreateCompanionBuilder,
      $$ComprasTableUpdateCompanionBuilder,
      (Compra, $$ComprasTableReferences),
      Compra,
      PrefetchHooks Function({bool proveedorId, bool detallesCompraRefs})
    >;
typedef $$DetallesCompraTableCreateCompanionBuilder =
    DetallesCompraCompanion Function({
      Value<int> id,
      required int compraId,
      required int productoId,
      required int cantidad,
      required double precioUnitario,
    });
typedef $$DetallesCompraTableUpdateCompanionBuilder =
    DetallesCompraCompanion Function({
      Value<int> id,
      Value<int> compraId,
      Value<int> productoId,
      Value<int> cantidad,
      Value<double> precioUnitario,
    });

final class $$DetallesCompraTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DetallesCompraTable,
          DetallesCompraData
        > {
  $$DetallesCompraTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ComprasTable _compraIdTable(_$AppDatabase db) =>
      db.compras.createAlias(
        $_aliasNameGenerator(db.detallesCompra.compraId, db.compras.id),
      );

  $$ComprasTableProcessedTableManager get compraId {
    final $_column = $_itemColumn<int>('compra_id')!;

    final manager = $$ComprasTableTableManager(
      $_db,
      $_db.compras,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_compraIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductosTable _productoIdTable(_$AppDatabase db) =>
      db.productos.createAlias(
        $_aliasNameGenerator(db.detallesCompra.productoId, db.productos.id),
      );

  $$ProductosTableProcessedTableManager get productoId {
    final $_column = $_itemColumn<int>('producto_id')!;

    final manager = $$ProductosTableTableManager(
      $_db,
      $_db.productos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DetallesCompraTableFilterComposer
    extends Composer<_$AppDatabase, $DetallesCompraTable> {
  $$DetallesCompraTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnFilters(column),
  );

  $$ComprasTableFilterComposer get compraId {
    final $$ComprasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compraId,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableFilterComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableFilterComposer get productoId {
    final $$ProductosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableFilterComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetallesCompraTableOrderingComposer
    extends Composer<_$AppDatabase, $DetallesCompraTable> {
  $$DetallesCompraTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  $$ComprasTableOrderingComposer get compraId {
    final $$ComprasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compraId,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableOrderingComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableOrderingComposer get productoId {
    final $$ProductosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableOrderingComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetallesCompraTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetallesCompraTable> {
  $$DetallesCompraTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => column,
  );

  $$ComprasTableAnnotationComposer get compraId {
    final $$ComprasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compraId,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableAnnotationComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableAnnotationComposer get productoId {
    final $$ProductosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableAnnotationComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DetallesCompraTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DetallesCompraTable,
          DetallesCompraData,
          $$DetallesCompraTableFilterComposer,
          $$DetallesCompraTableOrderingComposer,
          $$DetallesCompraTableAnnotationComposer,
          $$DetallesCompraTableCreateCompanionBuilder,
          $$DetallesCompraTableUpdateCompanionBuilder,
          (DetallesCompraData, $$DetallesCompraTableReferences),
          DetallesCompraData,
          PrefetchHooks Function({bool compraId, bool productoId})
        > {
  $$DetallesCompraTableTableManager(
    _$AppDatabase db,
    $DetallesCompraTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetallesCompraTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetallesCompraTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetallesCompraTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> compraId = const Value.absent(),
                Value<int> productoId = const Value.absent(),
                Value<int> cantidad = const Value.absent(),
                Value<double> precioUnitario = const Value.absent(),
              }) => DetallesCompraCompanion(
                id: id,
                compraId: compraId,
                productoId: productoId,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int compraId,
                required int productoId,
                required int cantidad,
                required double precioUnitario,
              }) => DetallesCompraCompanion.insert(
                id: id,
                compraId: compraId,
                productoId: productoId,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DetallesCompraTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({compraId = false, productoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (compraId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.compraId,
                                referencedTable: $$DetallesCompraTableReferences
                                    ._compraIdTable(db),
                                referencedColumn:
                                    $$DetallesCompraTableReferences
                                        ._compraIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (productoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productoId,
                                referencedTable: $$DetallesCompraTableReferences
                                    ._productoIdTable(db),
                                referencedColumn:
                                    $$DetallesCompraTableReferences
                                        ._productoIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DetallesCompraTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DetallesCompraTable,
      DetallesCompraData,
      $$DetallesCompraTableFilterComposer,
      $$DetallesCompraTableOrderingComposer,
      $$DetallesCompraTableAnnotationComposer,
      $$DetallesCompraTableCreateCompanionBuilder,
      $$DetallesCompraTableUpdateCompanionBuilder,
      (DetallesCompraData, $$DetallesCompraTableReferences),
      DetallesCompraData,
      PrefetchHooks Function({bool compraId, bool productoId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductosTableTableManager get productos =>
      $$ProductosTableTableManager(_db, _db.productos);
  $$VentasTableTableManager get ventas =>
      $$VentasTableTableManager(_db, _db.ventas);
  $$DetallesVentaTableTableManager get detallesVenta =>
      $$DetallesVentaTableTableManager(_db, _db.detallesVenta);
  $$ProveedoresTableTableManager get proveedores =>
      $$ProveedoresTableTableManager(_db, _db.proveedores);
  $$ComprasTableTableManager get compras =>
      $$ComprasTableTableManager(_db, _db.compras);
  $$DetallesCompraTableTableManager get detallesCompra =>
      $$DetallesCompraTableTableManager(_db, _db.detallesCompra);
}
