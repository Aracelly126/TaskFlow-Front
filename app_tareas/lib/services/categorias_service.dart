import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categoria.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String baseUrl = 'http://192.168.1.249:3000/api';
final storage = const FlutterSecureStorage();

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