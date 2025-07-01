import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/tarea_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await inicializarNotificaciones();

  final prefs = await SharedPreferences.getInstance();
  final temaOscuro = prefs.getBool('temaOscuro') ?? false;

  runApp(MyApp(temaOscuro: temaOscuro));
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode;
  ThemeProvider(this._themeMode);

  ThemeMode get themeMode => _themeMode;

  void setTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('temaOscuro', isDark);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  final bool temaOscuro;
  const MyApp({super.key, required this.temaOscuro});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TareaProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(temaOscuro ? ThemeMode.dark : ThemeMode.light)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'App Tareas',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorScheme: ColorScheme.dark(
              primary: Colors.blue,
              secondary: Colors.deepPurple,
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: const NotificationInitializer(),
        ),
      ),
    );
  }
}

class NotificationInitializer extends StatefulWidget {
  const NotificationInitializer({super.key});

  @override
  State<NotificationInitializer> createState() => _NotificationInitializerState();
}

class _NotificationInitializerState extends State<NotificationInitializer> {
  bool _cargando = true;
  bool _autenticado = false;

  @override
  void initState() {
    super.initState();
    inicializar();
  }

  Future<void> inicializar() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');
    final nombre = prefs.getString('nombre');
    final email = prefs.getString('email');
    final id = prefs.getInt('id');

    if (token != null && nombre != null && email != null && id != null) {
      // Usamos el método setUsuario
      authProvider.setUsuarioManual(id, nombre, email, token);
      _autenticado = true;
    }

    final notificaciones = prefs.getBool('notificaciones') ?? true;
    final hora = prefs.getString('horaNotificacion') ?? '08:00';

    if (notificaciones) {
      await NotificationService.reprogramarNotificacionDiaria(context, hora);
    }

    setState(() {
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const SplashScreen(); // Pantalla de carga
    }

    return _autenticado ? const HomeScreen() : const LoginScreen();
  }
}
