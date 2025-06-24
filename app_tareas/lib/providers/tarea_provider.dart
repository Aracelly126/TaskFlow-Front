import 'package:flutter/material.dart';
import '../models/tarea.dart';
import '../services/tareas_service.dart';

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
    final tareasBackend = await obtenerTareas();
    _tareas = tareasBackend;
    notifyListeners();
  }

  void actualizarTarea(Tarea tareaActualizada) {
  final index = _tareas.indexWhere((t) => t.id == tareaActualizada.id);
  if (index != -1) {
    _tareas[index] = tareaActualizada;
    notifyListeners();
  }
}
}