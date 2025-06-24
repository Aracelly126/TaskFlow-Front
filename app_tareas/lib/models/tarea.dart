class Tarea {
  final int id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final bool completada;
  final int categoriaId;
  final DateTime? fechaCompletada;

  Tarea({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.completada,
    required this.categoriaId,
    this.fechaCompletada,
  });

  factory Tarea.fromJson(Map<String, dynamic> json) => Tarea(
        id: json['id'],
        titulo: json['titulo'],
        descripcion: json['descripcion'],
        fecha: DateTime.parse(json['fecha']),
        completada: json['completada'] == 1 || json['completada'] == true,
        categoriaId: json['categoria_id'],
        fechaCompletada: json['fecha_completada'] != null
          ? DateTime.parse(json['fecha_completada'])
          : null,
      );
}