import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/tarea.dart';

const String baseUrl = 'http://192.168.1.249:3000/api';
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