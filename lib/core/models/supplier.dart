class Supplier {
  final int? id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? rfc;
  final DateTime createdAt;

  Supplier({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.rfc,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'rfc': rfc,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      rfc: map['rfc'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
