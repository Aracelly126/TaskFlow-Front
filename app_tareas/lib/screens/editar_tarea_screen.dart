import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tarea_provider.dart';
import '../services/tareas_service.dart';
import '../models/tarea.dart';
import '../services/categorias_service.dart';
import '../models/categoria.dart';

class EditarTareaScreen extends StatefulWidget {
  final Tarea tarea;

  const EditarTareaScreen({super.key, required this.tarea});

  @override
  State<EditarTareaScreen> createState() => _EditarTareaScreenState();
}

class _EditarTareaScreenState extends State<EditarTareaScreen> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime? _fechaSeleccionada;
  List<Categoria> _categorias = [];
  Categoria? _categoriaSeleccionada;
  bool _cargandoCategorias = true;

  @override
  void initState() {
    super.initState();
    _tituloController.text = widget.tarea.titulo;
    _descripcionController.text = widget.tarea.descripcion;
    _fechaSeleccionada = widget.tarea.fecha;
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    final cats = await obtenerCategorias();
    setState(() {
      _categorias = cats;
      _categoriaSeleccionada = _categorias.firstWhere(
        (cat) => cat.id == widget.tarea.categoriaId,
        orElse: () => _categorias.first,
      );
      _cargandoCategorias = false;
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _actualizarTarea() async {
    if (_tituloController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        _fechaSeleccionada == null ||
        _categoriaSeleccionada == null) return;

    final exito = await actualizarTarea(
      id: widget.tarea.id,
      titulo: _tituloController.text,
      descripcion: _descripcionController.text,
      categoriaId: _categoriaSeleccionada!.id,
      fecha: _fechaSeleccionada!,
      completada: widget.tarea.completada,
    );

    if (exito) {
      await Provider.of<TareaProvider>(context, listen: false).fetchTareas();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar la tarea')),
      );
    }
  }

  void _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Tarea')),
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _actualizarTarea,
                    child: const Text('Actualizar Tarea'),
                  ),
                ],
              ),
      ),
    );
  }
}