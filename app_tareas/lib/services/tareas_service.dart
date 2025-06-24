import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/tarea.dart';

const String baseUrl = 'http://10.0.2.2:3000/api';
final storage = FlutterSecureStorage();

Future<List<Tarea>> obtenerTareas() async {
  final token = await storage.read(key: 'jwt_token');
  final response = await http.get(
    Uri.parse('$baseUrl/tareas'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => Tarea.fromJson(e)).toList();
  }
  return [];
}

Future<bool> crearTarea(
  String titulo,
  String descripcion,
  int categoriaId,
  DateTime fecha, {
  String? hora,
}) async {
  final token = await storage.read(key: 'jwt_token');
  final response = await http.post(
    Uri.parse('$baseUrl/tareas'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String().split('T')[0],
      'hora': hora ?? '',
      'categoria_id': categoriaId,
    }),
  );
  return response.statusCode == 201;
}

Future<bool> eliminarTareaService(int id) async {
  final token = await storage.read(key: 'jwt_token');
  final response = await http.delete(
    Uri.parse('$baseUrl/tareas/$id'),
    headers: {'Authorization': 'Bearer $token'},
  );
  return response.statusCode == 200;
}

Future<bool> completarTarea(int id, bool completada) async {
  final token = await storage.read(key: 'jwt_token');
  try {
    final response = await http.patch(
      Uri.parse('$baseUrl/tareas/$id/completar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      return false;
    }
  } catch (e) {
    print('Exception in completarTarea: $e');
    return false;
  }
}

Future<bool> actualizarTarea({
  required int id,
  required String titulo,
  required String descripcion,
  required int categoriaId,
  required DateTime fecha,
  String? hora,
  required bool completada,
}) async {
  final token = await storage.read(key: 'jwt_token');
  final response = await http.put(
    Uri.parse('$baseUrl/tareas/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String().split('T')[0],
      'hora': hora ?? '',
      'categoria_id': categoriaId,
      'completada': completada,
    }),
  );
  return response.statusCode == 200;
}