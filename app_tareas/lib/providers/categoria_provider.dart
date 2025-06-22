import 'package:flutter/material.dart';
import '../models/categoria.dart';

class CategoriaProvider with ChangeNotifier {
  List<Categoria> _categorias = [];

  List<Categoria> get categorias => _categorias;

  void setCategorias(List<Categoria> categorias) {
    _categorias = categorias;
    notifyListeners();
  }

  void agregarCategoria(Categoria categoria) {
    _categorias.add(categoria);
    notifyListeners();
  }

  void eliminarCategoria(int id) {
    _categorias.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}