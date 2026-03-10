class TaxConfig {
  final int? id;
  final String name;
  final double percentage;
  final bool isActive;
  final bool isDefault;
  final DateTime createdAt;

  TaxConfig({
    this.id,
    required this.name,
    required this.percentage,
    this.isActive = true,
    this.isDefault = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  static TaxConfig get zero => TaxConfig(id: null, name: 'Sin IVA', percentage: 0.0, isDefault: true);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'percentage': percentage,
      'is_active': isActive ? 1 : 0,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TaxConfig.fromMap(Map<String, dynamic> map) {
    return TaxConfig(
      id: map['id'],
      name: map['name'] ?? '',
      percentage: (map['percentage'] ?? 0).toDouble(),
      isActive: (map['is_active'] ?? 1) == 1,
      isDefault: (map['is_default'] ?? 0) == 1,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }

  double calculateTax(double amount) => amount * (percentage / 100);
  double calculateTotal(double amount) => amount + calculateTax(amount);
}
