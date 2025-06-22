class Tarea {
  final int id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final bool completada;
  final int categoriaId;

  Tarea({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.completada,
    required this.categoriaId,
  });

  factory Tarea.fromJson(Map<String, dynamic> json) => Tarea(
        id: json['id'],
        titulo: json['titulo'],
        descripcion: json['descripcion'],
        fecha: DateTime.parse(json['fecha']),
        completada: json['completada'] == 1 || json['completada'] == true,
        categoriaId: json['categoria_id'],
      );
}