import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tarea_provider.dart';
import '../services/tareas_service.dart';
import '../models/tarea.dart';
import '../services/categorias_service.dart';
import '../models/categoria.dart';
import '../services/notification_service.dart';

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

  List<Categoria> _categorias = [];
  Categoria? _categoriaSeleccionada;
  bool _cargandoCategorias = true;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    final cats = await obtenerCategorias();
    setState(() {
      _categorias = cats;
      if (_categorias.isNotEmpty) {
        _categoriaSeleccionada = _categorias.first;
      }
      _cargandoCategorias = false;
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _guardarTarea() async {
    if (_tituloController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        _fechaSeleccionada == null ||
        _categoriaSeleccionada == null) return;

    String? horaStr = _horaSeleccionada != null
        ? '${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}:00'
        : '';

    bool exito = await crearTarea(
      _tituloController.text,
      _descripcionController.text,
      _categoriaSeleccionada!.id,
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
        categoriaId: _categoriaSeleccionada!.id,
      );
      await programarNotificacionTarea(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        titulo: _tituloController.text,
        descripcion: _descripcionController.text,
        fechaHora: _fechaSeleccionada!,
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
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: hoy,
      firstDate: DateTime(hoy.year, hoy.month, hoy.day),
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
        child: _cargandoCategorias
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                  DropdownButtonFormField<Categoria>(
                    value: _categoriaSeleccionada,
                    items: _categorias
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat.nombre),
                            ))
                        .toList(),
                    onChanged: (cat) {
                      setState(() {
                        _categoriaSeleccionada = cat;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Categoría'),
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