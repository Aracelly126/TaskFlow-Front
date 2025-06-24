import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz; 
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/tarea_provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> inicializarNotificaciones() async {
  // Initialize time zone data
  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(); // For iOS 

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS, // Add iOS support
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tap 
      print('Notification tapped: ${response.payload}');
    },
  );

  // Create or update the notification channel 
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'tareas_channel', // Channel ID
    'Tareas', // Channel name
    description: 'Recordatorios de tareas', // Channel description
    importance: Importance.max, // Controls both importance and priority
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> programarNotificacionTarea({
  required int id,
  required String titulo,
  required String descripcion,
  required DateTime fechaHora,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final notificacionesActivas = prefs.getBool('notificaciones') ?? true;
  if (!notificacionesActivas) return;
  await flutterLocalNotificationsPlugin.show(
    id,
    titulo,
    descripcion,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'tareas_channel',
        'Tareas',
        channelDescription: 'Recordatorios de tareas',
        importance: Importance.max,
        enableLights: true,
        ledColor: Colors.blue,
        ledOnMs: 1000,
        ledOffMs: 500,
        enableVibration: true,
      ),
    ),
  );
}

class NotificationService {
  static const int idNotificacionDiaria = 1000;

  static Future<void> reprogramarNotificacionDiaria(BuildContext context, String hora) async {
    // Cancelar notificación previa
    await cancelarNotificacionDiaria();
    // Obtener tareas del provider
    final provider = Provider.of<TareaProvider>(context, listen: false);
    await provider.fetchTareas();
    final hoy = DateTime.now();
    final tareasHoy = provider.tareas.where((t) =>
      !t.completada &&
      t.fecha.year == hoy.year &&
      t.fecha.month == hoy.month &&
      t.fecha.day == hoy.day
    ).toList();
    if (tareasHoy.isEmpty) return;
    // Programar notificación diaria a la hora indicada
    final partes = hora.split(':');
    final now = DateTime.now();
    DateTime programada = DateTime(now.year, now.month, now.day, int.parse(partes[0]), int.parse(partes[1]));
    if (programada.isBefore(now)) {
      programada = programada.add(const Duration(days: 1));
    }
    await flutterLocalNotificationsPlugin.zonedSchedule(
      idNotificacionDiaria,
      'Tienes tareas pendientes para hoy',
      'Revisa tus tareas en la app',
      tz.TZDateTime.from(programada, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tareas_channel',
          'Tareas',
          channelDescription: 'Recordatorios de tareas',
          importance: Importance.max,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelarNotificacionDiaria() async {
    await flutterLocalNotificationsPlugin.cancel(idNotificacionDiaria);
  }
}