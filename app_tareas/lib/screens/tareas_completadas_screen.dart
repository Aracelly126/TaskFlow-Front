import 'package:flutter/material.dart';
import '../services/tareas_service.dart';
import '../widgets/tarea_item.dart';

class TareasCompletadasScreen extends StatefulWidget {
  const TareasCompletadasScreen({super.key});

  @override
  State<TareasCompletadasScreen> createState() => _TareasCompletadasScreenState();
}

class _TareasCompletadasScreenState extends State<TareasCompletadasScreen> {
  List tareas = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarTareas();
  }

  Future<void> cargarTareas() async {
    final todas = await obtenerTareas();
    setState(() {
      tareas = todas.where((t) => t.completada == true).toList();
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tareas Completadas')),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : tareas.isEmpty
              ? const Center(child: Text('No hay tareas completadas.'))
              : ListView.builder(
                  itemCount: tareas.length,
                  itemBuilder: (ctx, i) => TareaItem(
                    tarea: tareas[i],
                  ),
                ),
    );
  }
}