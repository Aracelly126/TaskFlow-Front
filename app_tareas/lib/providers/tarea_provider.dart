import 'package:flutter/material.dart';
import '../models/tarea.dart';

class TareaProvider with ChangeNotifier {
  List<Tarea> _tareas = [];

  List<Tarea> get tareas => _tareas;

  void setTareas(List<Tarea> tareas) {
    _tareas = tareas;
    notifyListeners();
  }

  void agregarTarea(Tarea tarea) {
    _tareas.add(tarea);
    notifyListeners();
  }

  void eliminarTarea(int id) {
    _tareas.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // Método para cargar tareas desde la base de datos o servicio
  Future<void> fetchTareas() async {
    // Aquí deberías obtener las tareas desde tu base de datos o API.
    // Ejemplo simulado:
    await Future.delayed(const Duration(milliseconds: 500)); // Simula carga
    _tareas = [
      // Ejemplo de tareas cargadas:
      // Tarea(id: 1, titulo: 'Tarea 1', descripcion: 'Descripción 1'),
      // Tarea(id: 2, titulo: 'Tarea 2', descripcion: 'Descripción 2'),
    ];
    notifyListeners();
  }
}