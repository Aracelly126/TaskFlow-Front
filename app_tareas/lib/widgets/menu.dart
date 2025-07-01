import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/bitacora_screen.dart';
import '../screens/home_screen.dart';
import '../screens/categorias_screen.dart';
import '../screens/login_screen.dart';
import '../screens/ajustes_screen.dart';
import '../screens/tareas_completadas_screen.dart';
import '../screens/calendario_screen.dart';
import '../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  Future<void> _guardarUltimaPantalla(String pantalla) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ultima_pantalla', pantalla);
  }

  String _obtenerSaludo() {
    final hora = DateTime.now().hour;
    if (hora >= 5 && hora < 12) {
      return '¡Buenos días!';
    } else if (hora >= 12 && hora < 18) {
      return '¡Buenas tardes!';
    } else {
      return '¡Buenas noches!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final nombre = auth.usuario?.nombre ?? 'Usuario';
    final correo = auth.usuario?.email ?? 'correo@ejemplo.com';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF6C63FF)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _obtenerSaludo(),
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  correo,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
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
            leading: const Icon(Icons.task, color: Color(0xFF6C63FF)),
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
            leading: const Icon(Icons.calendar_month, color: Color(0xFF6C63FF)),
            title: const Text('Calendario'),
            onTap: () async {
              Navigator.pop(context);
              await _guardarUltimaPantalla('calendario');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CalendarioScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle, color: Color(0xFF6C63FF)),
            title: const Text('Tareas Completadas'),
            onTap: () async {
              Navigator.pop(context);
              await _guardarUltimaPantalla('tareas_completadas');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const TareasCompletadasScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF6C63FF)),
            title: const Text('Ajustes'),
            onTap: () async {
              Navigator.pop(context);
              await _guardarUltimaPantalla('ajustes');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AjustesScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFF6C63FF)),
            title: const Text('Cerrar sesión'),
            onTap: () async {
              Navigator.pop(context);
              await Provider.of<AuthProvider>(
                context,
                listen: false,
              ).cerrarSesion();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
