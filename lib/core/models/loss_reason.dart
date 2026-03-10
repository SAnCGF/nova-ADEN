class LossReason {
  final String id;
  final String name;
  final String? description;
  final bool isCustom;
  final DateTime createdAt;

  LossReason({
    required this.id,
    required this.name,
    this.description,
    this.isCustom = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  static List<LossReason> get defaults => [
    LossReason(id: 'VENCIMIENTO', name: 'Vencimiento', description: 'Producto vencido'),
    LossReason(id: 'DANO', name: 'Daño', description: 'Producto dañado'),
    LossReason(id: 'ROBO', name: 'Robo/Hurto', description: 'Producto robado o hurtado'),
    LossReason(id: 'DEVOLUCION', name: 'Devolución Proveedor', description: 'Devolución a proveedor'),
    LossReason(id: 'MERMA', name: 'Merma Natural', description: 'Pérdida natural del producto'),
    LossReason(id: 'ERROR', name: 'Error Inventario', description: 'Error en conteo'),
    LossReason(id: 'OTRO', name: 'Otro', description: 'Otros motivos'),
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_custom': isCustom ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory LossReason.fromMap(Map<String, dynamic> map) {
    return LossReason(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      isCustom: (map['is_custom'] ?? 0) == 1,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }
}
