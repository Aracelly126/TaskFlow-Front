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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      child: ListTile(
        title: Text(
          titulo,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$contenido\nFecha: $fecha',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}