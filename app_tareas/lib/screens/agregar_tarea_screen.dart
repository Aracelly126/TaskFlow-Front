import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tarea_provider.dart';
import '../services/tareas_service.dart';
import '../models/tarea.dart';

class AgregarTareaScreen extends StatefulWidget {
  const AgregarTareaScreen({super.key});

  @override
  State<AgregarTareaScreen> createState() => _AgregarTareaScreenState();
}

class _AgregarTareaScreenState extends State<AgregarTareaScreen> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  TimeOfDay? _horaSeleccionada;
  DateTime? _fechaSeleccionada;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _guardarTarea() async {
    if (_tituloController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        _fechaSeleccionada == null) return;

    
    String? horaStr = _horaSeleccionada != null
    ? '${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}:00'
    : '';

    bool exito = await crearTarea(
      _tituloController.text,
      _descripcionController.text,
      1, // Cambia por el id de la categoría seleccionada si lo tienes
      _fechaSeleccionada!,
      hora: horaStr,
    );

    if (exito) {
      final nuevaTarea = Tarea(
        id: 0,
        titulo: _tituloController.text,
        descripcion: _descripcionController.text,
        fecha: _fechaSeleccionada!,
        completada: false,
        categoriaId: 1,
      );
      Provider.of<TareaProvider>(context, listen: false).agregarTarea(nuevaTarea);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear la tarea en el servidor')),
      );
    }
  }

  void _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  void _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() {
        _horaSeleccionada = hora;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Tarea')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _fechaSeleccionada == null
                        ? 'Sin fecha seleccionada'
                        : 'Fecha: ${_fechaSeleccionada!.toLocal().toString().split(' ')[0]}',
                  ),
                ),
                TextButton(
                  onPressed: _seleccionarFecha,
                  child: const Text('Seleccionar Fecha'),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _horaSeleccionada == null
                        ? 'Sin hora seleccionada'
                        : 'Hora: ${_horaSeleccionada!.format(context)}',
                  ),
                ),
                TextButton(
                  onPressed: _seleccionarHora,
                  child: const Text('Seleccionar Hora'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _guardarTarea,
              child: const Text('Guardar Tarea'),
            ),
          ],
        ),
      ),
    );
  }
}