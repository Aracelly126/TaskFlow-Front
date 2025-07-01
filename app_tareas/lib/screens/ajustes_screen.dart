import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../main.dart';
import '../widgets/menu.dart';
import '../services/notification_service.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  bool _notificaciones = true;
  bool _temaOscuro = false;
  String _ordenTareas = 'fecha';
  String _horaNotificacion = '08:00';

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificaciones = prefs.getBool('notificaciones') ?? true;
      _temaOscuro = prefs.getBool('temaOscuro') ?? false;
      _ordenTareas = prefs.getString('ordenTareas') ?? 'fecha';
      _horaNotificacion = prefs.getString('horaNotificacion') ?? '08:00';
    });
  }

  Future<void> _guardarPreferencia(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  Future<void> _solicitarPermisoNotificaciones(BuildContext context) async {
    final status = await Permission.notification.request();
    String mensaje;
    if (status.isGranted) {
      mensaje = 'Permiso de notificaciones concedido';
    } else if (status.isDenied) {
      mensaje = 'Permiso de notificaciones denegado';
    } else if (status.isPermanentlyDenied) {
      mensaje = 'Permiso denegado permanentemente. Habilítalo en ajustes del sistema.';
    } else {
      mensaje = 'Estado desconocido del permiso.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  void _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logueado');
    await prefs.remove('ultima_pantalla');
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Future<void> _seleccionarHoraNotificacion(BuildContext context) async {
    final partes = _horaNotificacion.split(':');
    final horaActual = TimeOfDay(hour: int.parse(partes[0]), minute: int.parse(partes[1]));
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horaActual,
    );
    if (picked != null) {
      final nuevaHora = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() => _horaNotificacion = nuevaHora);
      await _guardarPreferencia('horaNotificacion', nuevaHora);
      // Reprogramar notificación diaria
      if (_notificaciones) {
        // Llama al servicio para reprogramar la notificación diaria
        // (lo implementaremos en el servicio de notificaciones)
        await NotificationService.reprogramarNotificacionDiaria(context, nuevaHora);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<AuthProvider>(context).usuario;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const Menu(),
      body: ListView(
        children: [
          // Preferencias del usuario
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(usuario?.nombre ?? 'Usuario'),
            subtitle: Text(usuario?.email ?? 'correo@ejemplo.com'),
          ),
          const Divider(),
          // Tema claro/oscuro
          SwitchListTile(
            secondary: const Icon(Icons.brightness_6),
            title: const Text('Tema oscuro'),
            value: _temaOscuro,
            onChanged: (val) {
              setState(() => _temaOscuro = val);
              _guardarPreferencia('temaOscuro', val);
              themeProvider.setTheme(val);
            },
          ),
          // Orden de tareas
          ListTile(
            leading: const Icon(Icons.sort),
            title: const Text('Orden de tareas'),
            subtitle: Text(_ordenTareas == 'fecha'
                ? 'Por fecha'
                : _ordenTareas == 'alfabetico'
                    ? 'Alfabético'
                    : 'Por prioridad'),
            trailing: DropdownButton<String>(
              value: _ordenTareas,
              items: const [
                DropdownMenuItem(value: 'fecha', child: Text('Por fecha')),
                DropdownMenuItem(value: 'alfabetico', child: Text('Alfabético')),
                DropdownMenuItem(value: 'prioridad', child: Text('Por prioridad')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _ordenTareas = val);
                  _guardarPreferencia('ordenTareas', val);
                }
              },
            ),
          ),
          // Notificaciones on/off
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text('Permitir notificaciones'),
            value: _notificaciones,
            onChanged: (val) {
              setState(() => _notificaciones = val);
              _guardarPreferencia('notificaciones', val);
              if (val) {
                _solicitarPermisoNotificaciones(context);
                // Programar notificación diaria
                NotificationService.reprogramarNotificacionDiaria(context, _horaNotificacion);
              } else {
                // Cancelar notificación diaria
                NotificationService.cancelarNotificacionDiaria();
              }
            },
          ),
          // Selector de hora para la notificación diaria
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Hora de notificación diaria'),
            subtitle: Text('Notificar a las $_horaNotificacion'),
            onTap: () => _seleccionarHoraNotificacion(context),
          ),
          const Divider(),
          // Cerrar sesión
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: _cerrarSesion,
          ),
        ],
      ),
    );
  }
}