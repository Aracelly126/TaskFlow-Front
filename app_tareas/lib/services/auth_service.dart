import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String baseUrl = 'http://10.66.6.146:3000/api';
final storage = const FlutterSecureStorage();

Future<Map<String, dynamic>?> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    await storage.write(key: 'jwt_token', value: data['token']);
    return data;  // Devuelvo todo el JSON con message, token, user
  }

  return null;  // O lanzar error según prefieras
}

Future<bool> register(String nombre, String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'nombre': nombre, 'email': email, 'password': password}),
  );
  return response.statusCode == 201;
}

// Función para solicitar recuperación de contraseña
Future<Map<String, dynamic>?> solicitarRecuperacionPassword(String email) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'message': data['message'],
        'userId': data['userId'], // Puede ser null si el email no existe
      };
    } else {
      final error = jsonDecode(response.body);
      return {
        'success': false,
        'message': error['error'] ?? 'Error desconocido',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Error de conexión: $e',
    };
  }
}

// Función para validar código de verificación
Future<Map<String, dynamic>?> validarCodigoVerificacion(String codigo, int userId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/validate-reset-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': codigo,
        'userId': userId,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'valid': data['valid'],
        'message': data['message'],
        'expiresAt': data['expiresAt'],
      };
    } else {
      final error = jsonDecode(response.body);
      return {
        'success': false,
        'message': error['error'] ?? 'Código inválido',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Error de conexión: $e',
    };
  }
}

// Función para restablecer contraseña con código
Future<Map<String, dynamic>?> restablecerPasswordConCodigo(String codigo, int userId, String nuevaPassword) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': codigo,
        'userId': userId,
        'newPassword': nuevaPassword,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'message': data['message'],
        'emailSent': data['emailSent'],
      };
    } else {
      final error = jsonDecode(response.body);
      return {
        'success': false,
        'message': error['error'] ?? 'Error al restablecer contraseña',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Error de conexión: $e',
    };
  }
}