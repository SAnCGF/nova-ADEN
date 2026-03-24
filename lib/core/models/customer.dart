class Customer {
  final int? id;
  final String nombre;
  final String carnetIdentidad;
  final String telefono;
  final String? email;
  final String? direccion;

  Customer({
    this.id,
    required this.nombre,
    required this.carnetIdentidad,
    required this.telefono,
    this.email,
    this.direccion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'carnetIdentidad': carnetIdentidad,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      nombre: map['nombre'] ?? '',
      carnetIdentidad: map['carnetIdentidad'] ?? '',
      telefono: map['telefono'] ?? '',
      email: map['email'],
      direccion: map['direccion'],
    );
  }
}
