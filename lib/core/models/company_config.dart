class CompanyConfig {
  final String name;
  final String? rfc;
  final String? address;
  final String? phone;
  final String? email;
  final String? logo;
  final String? footer;

  const CompanyConfig({
    required this.name,
    this.rfc,
    this.address,
    this.phone,
    this.email,
    this.logo,
    this.footer = 'Gracias por su compra',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rfc': rfc,
      'address': address,
      'phone': phone,
      'email': email,
      'logo': logo,
      'footer': footer,
    };
  }

  factory CompanyConfig.fromMap(Map<String, dynamic> map) {
    return CompanyConfig(
      name: map['name'] ?? '',
      rfc: map['rfc'],
      address: map['address'],
      phone: map['phone'],
      email: map['email'],
      logo: map['logo'],
      footer: map['footer'] ?? 'Gracias por su compra',
    );
  }

  static const CompanyConfig empty = CompanyConfig(name: '');
}
