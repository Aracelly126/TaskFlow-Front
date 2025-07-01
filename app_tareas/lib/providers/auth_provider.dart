import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';

class AuthProvider with ChangeNotifier {
  Usuario? _usuario;
  String? _token;

  Usuario? get usuario => _usuario;
  String? get token => _token;

  void setUsuario(Usuario usuario, String token) async {
    _usuario = usuario;
    _token = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('nombre', usuario.nombre);
    await prefs.setString('email', usuario.email);
    await prefs.setInt('id', usuario.id);

    notifyListeners();
  }

  // Método usado al arrancar la app desde SharedPreferences
  void setUsuarioManual(int id, String nombre, String email, String token) {
    _usuario = Usuario(id: id, nombre: nombre, email: email);
    _token = token;
    notifyListeners();
  }

  Future<void> cerrarSesion() async {
    _usuario = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('nombre');
    await prefs.remove('email');
    await prefs.remove('id');

    notifyListeners();
  }
}
