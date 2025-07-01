import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String baseUrl = 'http://10.66.6.146:3000/api';
final storage = FlutterSecureStorage();

Future<List<Map<String, dynamic>>> obtenerNotas() async {
  final token = await storage.read(key: 'jwt_token');
  final response = await http.get(
    Uri.parse('$baseUrl/bitacora'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }
  return [];
}

Future<bool> crearNota(String titulo, String contenido) async {
  final token = await storage.read(key: 'jwt_token');
  final response = await http.post(
    Uri.parse('$baseUrl/bitacora'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'titulo': titulo,
      'contenido': contenido,
      'fecha': DateTime.now().toIso8601String(),
    }),
  );
  return response.statusCode == 201;
}

Future<bool> editarNota(int id, String titulo, String contenido) async {
  final token = await storage.read(key: 'jwt_token');
  final response = await http.put(
    Uri.parse('$baseUrl/bitacora/$id'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'titulo': titulo,
      'contenido': contenido,
    }),
  );
  return response.statusCode == 200;
}

Future<bool> eliminarNota(int id) async {
  final token = await storage.read(key: 'jwt_token');
  final response = await http.delete(
    Uri.parse('$baseUrl/bitacora/$id'),
    headers: {'Authorization': 'Bearer $token'},
  );
  return response.statusCode == 200;
}