import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class HttpHelper {
  
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

  /// Realizar una petición PUT con manejo de errores
  static Future<Map<String, dynamic>> put(
    String url, 
    dynamic body, 
    {Map<String, String>? headers, bool suppressErrors = false}
  ) async {
    try {
      final completeHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };

      final response = await http.put(
        Uri.parse(url),
        headers: completeHeaders,
        body: jsonEncode(body),
      );

      return _processResponse(response, suppressErrors: suppressErrors);
    } catch (e) {
      if (!suppressErrors) {
        _showErrorSnackbar('Error de conexión', 'No se pudo conectar al servidor');
      }
      return {
        'success': false,
        'error': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Realizar una petición DELETE con manejo de errores
  static Future<Map<String, dynamic>> delete(
    String url, 
    {Map<String, String>? headers, bool suppressErrors = false}
  ) async {
    try {
      final completeHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };

      final response = await http.delete(
        Uri.parse(url),
        headers: completeHeaders,
      );

      return _processResponse(response, suppressErrors: suppressErrors);
    } catch (e) {
      if (!suppressErrors) {
        _showErrorSnackbar('Error de conexión', 'No se pudo conectar al servidor');
      }
      return {
        'success': false,
        'error': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Realizar una petición PATCH con manejo de errores
  static Future<Map<String, dynamic>> patch(
    String url, 
    dynamic body, 
    {Map<String, String>? headers, bool suppressErrors = false}
  ) async {
    try {
      final completeHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };

      final response = await http.patch(
        Uri.parse(url),
        headers: completeHeaders,
        body: jsonEncode(body),
      );

      return _processResponse(response, suppressErrors: suppressErrors);
    } catch (e) {
      if (!suppressErrors) {
        _showErrorSnackbar('Error de conexión', 'No se pudo conectar al servidor');
      }
      return {
        'success': false,
        'error': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  
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

  
  static Map<String, dynamic> _processResponse(http.Response response, {bool suppressErrors = false}) {
    print('🔷 Response Status: ${response.statusCode}');
    print('🔷 Response Body: ${response.body}');
    print('🔷 Response Headers: ${response.headers}');
    print('🔷 Response Body Length: ${response.body.length}');
    print('🔷 Response Body Type: ${response.body.runtimeType}');
    
    try {
      // Verificar si el body está vacío
      if (response.body.isEmpty) {
        print('⚠️ Response body is empty');
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return {
            'success': true,
            'data': {},
            'statusCode': response.statusCode
          };
        }
      }
      
      // Intentar decodificar JSON
      print('🔧 Attempting to decode JSON...');
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      print('✅ JSON decoded successfully: $responseBody');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': responseBody,
          'statusCode': response.statusCode
        };
      } else {
        String errorMessage = responseBody['message'] ?? 
                             'Error (Código: ${response.statusCode})';
        
        
        errorMessage = _getErrorMessage(response.statusCode, responseBody);
        
        
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
      print('❌ Response body that failed to parse: "${response.body}"');
      print('❌ Response body bytes: ${response.bodyBytes}');
      
      
      String detailedError = 'Error al procesar la respuesta';
      if (e.toString().contains('FormatException')) {
        detailedError = 'Respuesta del servidor no es JSON válido';
      } else if (e.toString().contains('type')) {
        detailedError = 'Formato de respuesta inesperado';
      }
      
      _showErrorSnackbar('Error', detailedError);
      return {
        'success': false,
        'error': 'Error procesando respuesta: ${e.toString()}',
        'statusCode': response.statusCode,
        'rawBody': response.body
      };
    }
  }

  
  static void _showErrorSnackbar(String title, String message) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text('$title: $message'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  
  static String _getErrorMessage(int statusCode, Map<String, dynamic> responseBody) {
    return switch (statusCode) {
      401 => 'Sesión expirada o credenciales inválidas',
      403 => 'No tienes permisos para realizar esta acción',
      404 => 'Recurso no encontrado',
      409 => responseBody['message'] ?? 'Conflicto con datos existentes',
      429 => 'Demasiadas solicitudes, intenta más tarde',
      >= 500 => 'Error del servidor, intente más tarde',
      _ => responseBody['message'] ?? 'Error (Código: $statusCode)',
    };
  }
}
