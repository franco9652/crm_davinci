import 'dart:convert';
import 'package:crm_app_dv/core/contants/app_constants.dart';
import 'package:crm_app_dv/models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSource(this.client);

  Future<String> login(String email, String password) async {
    final response = await client.post(
      Uri.parse(AppConstants.loginEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['token'];
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

  Future<void> sendPasswordRecoveryEmail(String email) async {
    final response = await client.post(
      Uri.parse('${AppConstants.baseUrl}/recovery'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al enviar el correo de recuperación');
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
}
