import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String baseUrl = 'http://192.168.1.249:3000/api';
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