class Customer {
  final int? id;
  final String name;
  final String? identity;
  final String? phone;
  final String? email;
  final double totalPurchases;
  final int visitCount;
  final DateTime createdAt;

  Customer({
    this.id,
    required this.name,
    this.identity,
    this.phone,
    this.email,
    this.totalPurchases = 0.0,
    this.visitCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'identity': identity,
      'phone': phone,
      'email': email,
      'total_purchases': totalPurchases,
      'visit_count': visitCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'] ?? '',
      identity: map['identity'],
      phone: map['phone'],
      email: map['email'],
      totalPurchases: (map['total_purchases'] ?? 0).toDouble(),
      visitCount: map['visit_count'] ?? 0,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
    );
  }
}
