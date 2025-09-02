import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Helper class para manejar peticiones HTTP con gestión de errores consistente
class HttpHelper {
  /// Realizar una petición GET con manejo de errores
  static Future<Map<String, dynamic>> get(String url, {Map<String, String>? headers, bool suppressErrors = false}) async {
    try {
      final completeHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };
      
      print('🔷 GET Request: $url');
      print('🔷 Headers: $completeHeaders');
      
      final response = await http.get(
        Uri.parse(url),
        headers: completeHeaders,
      );
      
      return _processResponse(response, suppressErrors: suppressErrors);
    } catch (e) {
      print('❌ Error en petición GET: $e');
      _showErrorSnackbar('Error de conexión', 'No se pudo conectar con el servidor');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Realizar una petición POST con manejo de errores
  static Future<Map<String, dynamic>> post(
    String url, 
    dynamic body, 
    {Map<String, String>? headers}
  ) async {
    try {
      final completeHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };
      
      final bodyString = jsonEncode(body);
      print('🔷 POST Request: $url');
      print('🔷 Headers: $completeHeaders');
      print('🔷 Body: $bodyString');
      
      final response = await http.post(
        Uri.parse(url),
        headers: completeHeaders,
        body: bodyString,
      );
      
      return _processResponse(response);
    } catch (e) {
      print('❌ Error en petición POST: $e');
      _showErrorSnackbar('Error de conexión', 'No se pudo conectar con el servidor');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Procesar la respuesta HTTP
  static Map<String, dynamic> _processResponse(http.Response response, {bool suppressErrors = false}) {
    print('🔷 Response Status: ${response.statusCode}');
    print('🔷 Response Body: ${response.body}');
    
    try {
      final Map<String, dynamic> responseBody = 
          response.body.isNotEmpty ? jsonDecode(response.body) : {};
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': responseBody,
          'statusCode': response.statusCode
        };
      } else {
        String errorMessage = responseBody['message'] ?? 
                             'Error (Código: ${response.statusCode})';
        
        // Manejar errores comunes
        if (response.statusCode == 401) {
          errorMessage = 'Sesión expirada o credenciales inválidas';
          // Podría añadirse aquí lógica para redirigir al login
        } else if (response.statusCode == 403) {
          errorMessage = 'No tienes permisos para realizar esta acción';
        } else if (response.statusCode == 404) {
          errorMessage = 'Recurso no encontrado';
        } else if (response.statusCode == 409) {
          errorMessage = responseBody['message'] ?? 'Conflicto con datos existentes';
        } else if (response.statusCode == 429) {
          errorMessage = 'Demasiadas solicitudes, intenta más tarde';
        } else if (response.statusCode >= 500) {
          errorMessage = 'Error del servidor, intente más tarde';
        }
        
        // Evitar snackbar en ciertos casos (por ejemplo, 404 en listados vacíos)
        if (!suppressErrors && response.statusCode != 404) {
          _showErrorSnackbar('Error', errorMessage);
        }
        
        return {
          'success': false,
          'error': errorMessage,
          'data': responseBody,
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      print('❌ Error procesando respuesta: $e');
      _showErrorSnackbar('Error', 'Error al procesar la respuesta');
      return {
        'success': false,
        'error': 'Error procesando respuesta: ${e.toString()}',
        'statusCode': response.statusCode
      };
    }
  }

  /// Mostrar snackbar de error
  static void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red[400],
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 3),
    );
  }
}
