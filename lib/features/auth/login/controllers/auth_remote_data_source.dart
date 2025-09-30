import 'dart:convert';
import 'package:crm_app_dv/core/contants/app_constants.dart';
import 'package:crm_app_dv/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSource(this.client);

  /// 🔧 **Procesa respuestas HTTP incluyendo rate limiting**
  Future<Map<String, dynamic>> _processResponse(http.Response response) async {
    switch (response.statusCode) {
      case 200:
      case 201:
        return {'success': true, 'data': jsonDecode(response.body)};
      
      case 429: // Rate Limit
        final body = jsonDecode(response.body);
        final retryAfter = response.headers['retry-after'];
        
        print('🚫 Rate limited - Retry after: ${retryAfter}s');
        
        return {
          'success': false,
          'rateLimited': true,
          'error': body['error'] ?? 'Demasiadas solicitudes',
          'retryAfter': retryAfter != null ? int.parse(retryAfter) : 300,
        };
      
      case 400:
      case 401:
      case 404:
        final body = jsonDecode(response.body);
        return {
          'success': false,
          'error': body['message'] ?? body['error'] ?? 'Error en la solicitud',
        };
      
      default:
        return {
          'success': false,
          'error': 'Error del servidor (${response.statusCode})',
        };
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await client.post(
      Uri.parse(AppConstants.loginEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final result = await _processResponse(response);
    
    // 🚫 **Manejo específico de rate limit en login**
    if (result['rateLimited'] == true) {
      return {
        'success': false,
        'error': 'Demasiados intentos de login. Espera ${result['retryAfter']} segundos.',
        'rateLimited': true,
        'cooldownTime': result['retryAfter'],
      };
    }

    // ✅ **Login exitoso**
    if (result['success'] == true) {
      final body = result['data'];
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
        'success': true,
        'token': token,
        'role': roleStr,
      };
    }

    // ❌ **Error en login**
    return {
      'success': false,
      'error': result['error'] ?? 'Error al iniciar sesión',
    };
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

      final result = await _processResponse(response);
      
      // 🚫 **Manejo específico de rate limit en emails**
      if (result['rateLimited'] == true) {
        return {
          'success': false,
          'message': 'Límite de emails alcanzado. Espera ${result['retryAfter']} segundos.',
          'rateLimited': true,
          'cooldownTime': result['retryAfter'],
        };
      }

      // ✅ **Email enviado exitosamente**
      if (result['success'] == true) {
        final responseData = result['data'];
        return {
          'success': true,
          'message': responseData['message'] ?? 'Se ha enviado un correo de recuperación',
        };
      }

      // ❌ **Error al enviar email**
      return {
        'success': false,
        'message': result['error'] ?? 'Error al enviar el correo de recuperación',
      };
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
