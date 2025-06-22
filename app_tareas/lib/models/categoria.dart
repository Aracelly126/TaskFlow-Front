class Categoria {
  final int id;
  final String nombre;
  final String color;
  final String icono;

  Categoria({
    required this.id,
    required this.nombre,
    required this.color,
    required this.icono,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
        id: json['id'],
        nombre: json['nombre'],
        color: json['color'],
        icono: json['icono'],
      );
}