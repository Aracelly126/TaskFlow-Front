import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/bitacora_screen.dart';
import '../screens/home_screen.dart';
import '../screens/categorias_screen.dart';
import '../screens/login_screen.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  Future<void> _guardarUltimaPantalla(String pantalla) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ultima_pantalla', pantalla);
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logueado');
    await prefs.remove('ultima_pantalla');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color:  Color(0xFF6C63FF),
            ),
            child: Center(
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.book, color: Color(0xFF6C63FF)),
            title: const Text('Bitácora'),
            onTap: () async {
              Navigator.pop(context);
              await _guardarUltimaPantalla('bitacora');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const BitacoraScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.task, color:  Color(0xFF6C63FF)),
            title: const Text('Tareas'),
            onTap: () async {
              Navigator.pop(context);
              await _guardarUltimaPantalla('tareas');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.category, color: Color(0xFF6C63FF)),
            title: const Text('Categorías'),
            onTap: () async {
              Navigator.pop(context);
              await _guardarUltimaPantalla('categorias');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CategoriasScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color:  Color(0xFF6C63FF)),
            title: const Text('Cerrar sesión'),
            onTap: () async {
              Navigator.pop(context);
              await _cerrarSesion(context);
            },
          ),
        ],
      ),
    );
  }
}