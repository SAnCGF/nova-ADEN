class Proveedor {
  final int id;
  final String nombre;
  final String? contacto;

  Proveedor({
    required this.id,
    required this.nombre,
    this.contacto,
  });

  factory Proveedor.nuevo({
    required String nombre,
    String? contacto,
  }) {
    return Proveedor(id: 0, nombre: nombre, contacto: contacto);
  }
}