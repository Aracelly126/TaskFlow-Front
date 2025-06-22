import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'bitacora_screen.dart';
import 'home_screen.dart';
import 'categorias_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<Widget> _pantallaInicial() async {
    final prefs = await SharedPreferences.getInstance();
    final logueado = prefs.getBool('logueado') == true;
    if (!logueado) return const LoginScreen();

    final ultima = prefs.getString('ultima_pantalla') ?? 'bitacora';
    switch (ultima) {
      case 'tareas':
        return const HomeScreen();
      case 'categorias':
        return const CategoriasScreen();
      case 'bitacora':
      default:
        return const BitacoraScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _pantallaInicial(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data!;
      },
    );
  }
}