import 'package:flutter/material.dart';
import '../models/usuario.dart';

class AuthProvider with ChangeNotifier {
  Usuario? _usuario;
  String? _token;

  Usuario? get usuario => _usuario;
  String? get token => _token;

  void setUsuario(Usuario usuario, String token) {
    _usuario = usuario;
    _token = token;
    notifyListeners();
  }

  void logout() {
    _usuario = null;
    _token = null;
    notifyListeners();
  }
}