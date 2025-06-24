import 'package:app_tareas/screens/editar_tarea_screen.dart';
import 'package:flutter/material.dart';
import '../models/tarea.dart';
import '../services/tareas_service.dart';
import 'package:provider/provider.dart';
import '../providers/tarea_provider.dart';

class TareaItem extends StatefulWidget {
  final Tarea tarea;

  const TareaItem({super.key, required this.tarea});

  @override
  State<TareaItem> createState() => _TareaItemState();
}

class _TareaItemState extends State<TareaItem> {
  bool _cargando = false;

  Future<void> _toggleCompletada() async {
    setState(() => _cargando = true);
    final exito = await completarTarea(widget.tarea.id, !widget.tarea.completada);
    if (exito) {
      await Provider.of<TareaProvider>(context, listen: false).fetchTareas();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo marcar la tarea como completada.')),
      );
    }
    setState(() => _cargando = false);
  }

  void _editarTarea() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarTareaScreen(tarea: widget.tarea),
      ),
    );
  }

  Future<void> _eliminarTarea() async {
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar esta tarea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _cargando = true);
      final exito = await eliminarTareaService(widget.tarea.id);
      if (exito) {
        Provider.of<TareaProvider>(context, listen: false).eliminarTarea(widget.tarea.id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar la tarea.')),
        );
      }
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.tarea.titulo),
      subtitle: Text(widget.tarea.descripcion),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_cargando)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else ...[
            IconButton(
              icon: Icon(
                widget.tarea.completada ? Icons.check_circle : Icons.radio_button_unchecked,
                color: widget.tarea.completada ? Colors.green : Colors.grey,
              ),
              onPressed: _toggleCompletada,
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: _editarTarea,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _eliminarTarea,
            ),
          ],
        ],
      ),
    );
  }
}