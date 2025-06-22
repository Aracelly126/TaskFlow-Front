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
}
