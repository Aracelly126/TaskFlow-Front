import 'package:flutter/material.dart';

class BitacoraItem extends StatelessWidget {
  final String titulo;
  final String contenido;
  final String fecha;
  final VoidCallback? onDelete;

  const BitacoraItem({
    super.key,
    required this.titulo,
    required this.contenido,
    required this.fecha,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        title: Text(titulo),
        subtitle: Text('$contenido\nFecha: $fecha'),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}