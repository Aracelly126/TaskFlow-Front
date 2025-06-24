import 'package:flutter/material.dart';
import '../services/tareas_service.dart';
import '../widgets/tarea_item.dart';
import '../models/tarea.dart';
import 'package:intl/intl.dart';
import '../widgets/menu.dart';

class TareasCompletadasScreen extends StatefulWidget {
  const TareasCompletadasScreen({super.key});

  @override
  State<TareasCompletadasScreen> createState() => _TareasCompletadasScreenState();
}

class _TareasCompletadasScreenState extends State<TareasCompletadasScreen> {
  List<Tarea> tareas = [];
  bool cargando = true;
  DateTime? filtroFecha;
  List<int> archivadas = [];

  @override
  void initState() {
    super.initState();
    filtroFecha = DateTime.now();
    cargarTareas();
  }

  Future<void> cargarTareas() async {
    final todas = await obtenerTareas();
    setState(() {
      tareas = todas.where((t) => t.completada == true).toList();
      cargando = false;
    });
  }

  List<Tarea> get tareasFiltradas {
    if (filtroFecha == null) {
      return tareas.where((t) => !archivadas.contains(t.id)).toList();
    }
    return tareas.where((t) {
      final fc = t.fechaCompletada ?? t.fecha;
      return fc.year == filtroFecha!.year &&
          fc.month == filtroFecha!.month &&
          fc.day == filtroFecha!.day &&
          !archivadas.contains(t.id);
    }).toList();
  }

  void _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: filtroFecha ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => filtroFecha = picked);
    }
  }

  void _archivarTareasAntiguas() {
    final hoy = DateTime.now();
    setState(() {
      archivadas.addAll(tareas.where((t) {
        final fc = t.fechaCompletada ?? t.fecha;
        return fc.isBefore(DateTime(hoy.year, hoy.month, hoy.day));
      }).map((t) => t.id));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tareas antiguas archivadas.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas Completadas'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Ver completadas de hoy',
            onPressed: () => setState(() => filtroFecha = hoy),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Filtrar por fecha',
            onPressed: _seleccionarFecha,
          ),
          IconButton(
            icon: const Icon(Icons.archive),
            tooltip: 'Archivar completadas antiguas',
            onPressed: _archivarTareasAntiguas,
          ),
        ],
      ),
      drawer: const Menu(),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : tareasFiltradas.isEmpty
              ? const Center(child: Text('No hay tareas completadas para este día.'))
              : RefreshIndicator(
                  onRefresh: () async {
                    await cargarTareas();
                  },
                  child: ListView.builder(
                    itemCount: tareasFiltradas.length,
                    itemBuilder: (ctx, i) => TareaItem(
                      tarea: tareasFiltradas[i],
                    ),
                  ),
                ),
    );
  }
}