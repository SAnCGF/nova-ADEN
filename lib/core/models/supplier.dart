class Supplier {
  final int? id;
  final String nombre;
  final String? telefono;
  final String? email;
  final String? direccion;

  Supplier({
    this.id,
    required this.nombre,
    this.telefono,
    this.email,
    this.direccion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      nombre: map['nombre'] ?? '',
      telefono: map['telefono'],
      email: map['email'],
      direccion: map['direccion'],
    );
  }
}
