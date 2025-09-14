import 'dart:convert';
import 'package:crm_app_dv/core/contants/app_constants.dart';
import 'package:crm_app_dv/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSource(this.client);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await client.post(
      Uri.parse(AppConstants.loginEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final token = body['token'];
      // Intentar obtener role en diferentes formatos de respuesta
      dynamic role = body['role'];
      role ??= body['user'] != null ? body['user']['role'] : null;
      role ??= (body['roles'] is List && body['roles'].isNotEmpty) ? body['roles'][0] : null;
      role ??= (body['user'] != null && body['user']['roles'] is List && body['user']['roles'].isNotEmpty)
          ? body['user']['roles'][0]
          : null;
      role ??= body['data'] != null ? body['data']['role'] : null;
      final roleStr = (role ?? '').toString();
      // Debug
      print('🔐 Login OK. token present=${token != null && token.toString().isNotEmpty}, roleRaw=$roleStr');
      return {
        'token': token,
        'role': roleStr,
      };
    } else {
      throw Exception('Error al iniciar sesión');
    }
  }

  Future<void> register(UserModel user) async {
    final response = await client.post(
      Uri.parse(AppConstants.registerEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al registrar');
    }
  }

  Future<Map<String, dynamic>> sendPasswordRecoveryEmail(String email) async {
    try {
      print('Enviando solicitud de recuperación a: ${AppConstants.baseUrl}/recovery');
      print('Email: $email');
      
      final response = await client.post(
        Uri.parse('${AppConstants.baseUrl}/recovery'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      
      print('Respuesta: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Se ha enviado un correo de recuperación',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al enviar el correo de recuperación',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Error en la recuperación de contraseña: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    final response = await client.post(
      Uri.parse('${AppConstants.baseUrl}/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al restablecer la contraseña');
    }
  }

  /// Cambia la contraseña del usuario
  /// 
  /// Requiere la contraseña actual y la nueva contraseña
  /// Retorna un mapa con `success` (bool) y `message` (String)
  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    try {
      // Obtener token de autenticación almacenado
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No hay sesión activa. Por favor, inicie sesión nuevamente.'
        };
      }
      
      print('🔵 Enviando solicitud de cambio de contraseña');
      
      final response = await client.post(
        Uri.parse('${AppConstants.baseUrl}/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword
        }),
      );
      
      print('🔵 Response status: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Contraseña actualizada correctamente'
        };
      }
      
      // Manejar diferentes errores
      Map<String, dynamic> result = {'success': false};
      
      if (response.body.isNotEmpty) {
        try {
          final errorBody = jsonDecode(response.body);
          result['message'] = errorBody['message'] ?? errorBody['error'] ?? 'Error al cambiar la contraseña';
        } catch (e) {
          result['message'] = 'Error en la respuesta del servidor';
        }
      } else {
        result['message'] = 'Error al cambiar la contraseña (${response.statusCode})';
      }
      
      return result;
    } catch (e) {
      print('❌ Error al cambiar la contraseña: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}
