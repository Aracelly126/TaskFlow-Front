import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/categoria.dart';

const String baseUrl = 'http://10.0.2.2:3000/api';
final storage = FlutterSecureStorage();

Future<List<Categoria>> obtenerCategorias() async {
  final token = await storage.read(key: 'jwt_token');
  final response = await http.get(
    Uri.parse('$baseUrl/categorias'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => Categoria.fromJson(e)).toList();
  }
  return [];
}

Future<bool> crearCategoria(String nombre, String color, String icono) async {
  final token = await storage.read(key: 'jwt_token');
  final response = await http.post(
    Uri.parse('$baseUrl/categorias'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'nombre': nombre, 'color': color, 'icono': icono}),
  );
  return response.statusCode == 201;
}

Future<bool> editarCategoria(int id, String nombre, String color, String icono) async {
  final token = await storage.read(key: 'jwt_token');
  final response = await http.put(
    Uri.parse('$baseUrl/categorias/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'nombre': nombre, 'color': color, 'icono': icono}),
  );
  return response.statusCode == 200;
}

Future<bool> eliminarCategoria(int id) async {
  final token = await storage.read(key: 'jwt_token');
  final response = await http.delete(
    Uri.parse('$baseUrl/categorias/$id'),
    headers: {'Authorization': 'Bearer $token'},
  );
  return response.statusCode == 200;
}