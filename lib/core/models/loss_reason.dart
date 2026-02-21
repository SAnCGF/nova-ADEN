class LossReason {
  final String id;
  final String name;
  final String description;
  final bool isActive;

  LossReason({
    required this.id,
    required this.name,
    this.description = '',
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory LossReason.fromMap(Map<String, dynamic> map) {
    return LossReason(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      isActive: map['is_active'] == 1,
    );
  }

  /// Motivos predefinidos para mermas (RF 27)
  static List<LossReason> getPredefinedReasons() {
    return [
      LossReason(id: 'VENCIMIENTO', name: 'Vencimiento', description: 'Producto vencido o por vencer'),
      LossReason(id: 'DANO', name: 'Daño', description: 'Producto dañado o deteriorado'),
      LossReason(id: 'ROBO', name: 'Robo/Hurto', description: 'Pérdida por robo o hurto'),
      LossReason(id: 'ERROR', name: 'Error Inventario', description: 'Error en conteo o registro'),
      LossReason(id: 'DEVOLUCION', name: 'Devolución Proveedor', description: 'Devolución a proveedor'),
      LossReason(id: 'PROMOCION', name: 'Promoción/Descuento', description: 'Merma por promoción'),
      LossReason(id: 'MUESTRA', name: 'Muestra Gratis', description: 'Producto usado como muestra'),
      LossReason(id: 'OTRO', name: 'Otro', description: 'Otros motivos no especificados'),
    ];
  }
}
