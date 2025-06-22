import 'package:flutter/material.dart';
import '../models/tarea.dart';

class TareaItem extends StatelessWidget {
  final Tarea tarea;

  const TareaItem({super.key, required this.tarea});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(tarea.titulo),
      subtitle: Text(tarea.descripcion),
      trailing: Icon(
        tarea.completada ? Icons.check_circle : Icons.radio_button_unchecked,
        color: tarea.completada ? Colors.green : Colors.grey,
      ),
    );
  }
}