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
  notifyListeners();
}

 void logout() async {
  _usuario = null;
  _token = null;
  
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
  notifyListeners();
}
Future<void> cargarToken() async {
  final prefs = await SharedPreferences.getInstance();
  final tokenGuardado = prefs.getString('token');
  if (tokenGuardado != null) {
    _token = tokenGuardado;
   
    notifyListeners();
  }
}
}