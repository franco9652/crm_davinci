import 'dart:convert';

import 'package:crm_app_dv/core/contants/app_constants.dart';
import 'package:crm_app_dv/core/utils/http_helper.dart';
import 'package:crm_app_dv/models/budget_model.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:crm_app_dv/models/work_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class CustomerRemoteDataSource {
  final http.Client client;

  CustomerRemoteDataSource(this.client);

  Future<void> createCustomer(CustomerModel customer) async {
    try {
      debugPrint('🔄 Creando cliente: ${customer.name}');
      
      // Obtener token de autorización
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      
      // Usar HttpHelper con headers de auth
      final response = await HttpHelper.post(
        '${AppConstants.baseUrl}/customerCreate',
        customer.toJson(),
        headers: headers,
      );
      
      if (response['success'] == true) {
        debugPrint('✅ Cliente creado exitosamente');
        return;
      } else {
        final errorMsg = response['error'] ?? 'Error desconocido al crear cliente';
        debugPrint('❌ Error creando cliente: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('❌ Excepción al crear cliente: $e');
      throw Exception('Error al crear el cliente: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getAllCustomers(int page) async {
    try {
      // Usar paginación del backend directamente
      final url = '${AppConstants.baseUrl}/customers?page=$page';
      debugPrint('🔄 Solicitando clientes a: $url');
      
      // Hacemos la solicitud a través del helper
      final response = await HttpHelper.get(url);
      
      // Verificar si la solicitud fue exitosa
      if (response['success'] != true) {
        debugPrint('❌ Error en la respuesta: ${response['error']}');
        throw Exception(response['error'] ?? 'Error al obtener clientes');
      }
      
      // El helper ya maneja errores HTTP básicos, aquí procesamos la respuesta
      final dynamic jsonResponse = response['data'];
      debugPrint('✅ Respuesta recibida tipo: ${jsonResponse.runtimeType}');
      
      // El backend ya maneja la paginación, usar directamente su respuesta
      if (jsonResponse is Map && jsonResponse.containsKey('customers')) {
        final customersData = jsonResponse['customers'] as List<dynamic>;
        final totalPages = jsonResponse['totalPages'] as int? ?? 1;
        final currentPage = jsonResponse['page'] as int? ?? 1;
        
        debugPrint('📋 Página $currentPage de $totalPages - ${customersData.length} clientes recibidos');
        
        // Convertir a CustomerModel
        List<CustomerModel> customers = [];
        int errorCount = 0;
        
        for (var i = 0; i < customersData.length; i++) {
          try {
            final data = customersData[i];
            debugPrint('🔍 Cliente #$i: ${data['name']} (${data['_id']})');
            
            if (data is Map && data.containsKey('name')) {
              final Map<String, dynamic> customerData = Map<String, dynamic>.from(data);
              final customer = CustomerModel.fromJson(customerData);
              customers.add(customer);
              debugPrint('✅ Cliente convertido: ${customer.name}');
            } else {
              debugPrint('⚠️ Cliente #$i no tiene campos mínimos');
              errorCount++;
            }
          } catch (e) {
            debugPrint('❌ Error al convertir cliente #$i: $e');
            errorCount++;
          }
        }
        
        if (errorCount > 0) {
          debugPrint('⚠️ $errorCount clientes no pudieron ser procesados');
        }
        
        debugPrint('✅ ${customers.length} clientes convertidos exitosamente');
        
        return <String, dynamic>{
          'customers': customers,
          'totalPages': totalPages,
          'currentPage': currentPage,
          'totalCount': customersData.length
        };
      } else {
        debugPrint('❌ Formato de respuesta inesperado: $jsonResponse');
        return <String, dynamic>{
          'customers': <CustomerModel>[],
          'totalPages': 1,
          'currentPage': 1,
          'totalCount': 0
        };
      }
    } catch (e, stackTrace) {
      // Log detallado del error
      debugPrint('❌❌❌ ERROR AL OBTENER CLIENTES:');
      debugPrint('💥 Excepción: $e');
      debugPrint('📍 StackTrace: \n$stackTrace');
      
      // Mensaje de error personalizado según tipo
      String errorMessage;
      
      // Verificar si es un error de timeout
      if (e.toString().contains('timeout')) {
        errorMessage = 'La conexión al servidor ha tardado demasiado. Por favor, inténtelo nuevamente.';
      }
      // Verificar si es un error de conexión 
      else if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused')) {
        errorMessage = 'No se pudo conectar al servidor. Verifique su conexión a internet.';
      }
      // Error general
      else {
        errorMessage = 'No se pudieron cargar los clientes: ${e.toString().split('\n').first}';
      }
      
      // Devolvemos un mapa con error para manejarlo mejor en el controlador
      return <String, dynamic>{
        'success': false,
        'error': errorMessage,
        'customers': <CustomerModel>[],
        'totalPages': 1
      };
    }
  }

  Future<List<WorkModel>> getWorksByUserId(String customerId) async {
    final response = await client.get(
      Uri.parse('${AppConstants.baseUrl}/workgetbyuser/$customerId'),
      headers: {'Content-Type': 'application/json'},
    );
    print("Llamando a: ${AppConstants.baseUrl}/workgetbyuser/$customerId");
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return (jsonResponse['works'] as List)
          .map((data) => WorkModel.fromJson(data))
          .toList();
    } else if (response.statusCode == 404) {
      return []; // Devuelve una lista vacía si no hay trabajos
    } else {
      throw Exception('Error al obtener los trabajos del usuario');
    }
  }

  Future<List<BudgetModel>> getBudgetsByCustomerId(String customerId) async {
    final response = await client.get(Uri.parse('${AppConstants.baseUrl}/budgets?customerId=$customerId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((budget) => BudgetModel.fromJson(budget)).toList();
    } else {
      throw Exception('Error al obtener los presupuestos del cliente');
    }
  }

  Future<Map<String, dynamic>> getCustomerById(String userId) async {
    try {
      debugPrint('🔎 Obteniendo cliente con ID: $userId');
      // Recuperar token para autorización
      String? token;
      try {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('auth_token');
      } catch (_) {}

      final headers = <String, String>{
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      // El customerId de meeting apunta al customer embebido, no al customer real
      // Necesitamos buscar por el _id del customer embebido en lugar del customerId
      print('🔍 Analizando customerId: $userId');
      
      // Intentar múltiples endpoints que funcionan en el proyecto
      final endpoints = [
        '${AppConstants.baseUrl}/getcustomersbyid/$userId',
        '${AppConstants.baseUrl}/customers/$userId', 
        '${AppConstants.baseUrl}/customer/$userId',
        // Probar con el _id del customer embebido que vimos en logs
        '${AppConstants.baseUrl}/getcustomersbyid/6893a93c4a9e9b8508717ee2',
        '${AppConstants.baseUrl}/customers/6893a93c4a9e9b8508717ee2',
      ];
      
      for (final url in endpoints) {
        debugPrint('🔷 Intentando GET Customer: $url');
        final resp = await HttpHelper.get(url, headers: headers, suppressErrors: true);
        
        if (resp['success'] == true) {
          final data = resp['data'];
          Map<String, dynamic>? found;
          
          if (data is Map) {
            // Formato: { customer: [...] }
            if (data['customer'] is List && (data['customer'] as List).isNotEmpty) {
              found = Map<String, dynamic>.from((data['customer'] as List).first);
            }
            // Formato: { customer: {...} }
            else if (data['customer'] is Map) {
              found = Map<String, dynamic>.from(data['customer'] as Map);
            }
            // Formato directo: { _id: ..., name: ..., contactNumber: ... }
            else if (data.containsKey('_id') || data.containsKey('name') || data.containsKey('contactNumber')) {
              found = Map<String, dynamic>.from(data);
            }
          }
          
          if (found != null && found.isNotEmpty) {
            debugPrint('✅ Cliente obtenido correctamente desde $url');
            debugPrint('📱 contactNumber: ${found['contactNumber']}');
            return found;
          }
        } else {
          debugPrint('❌ Endpoint $url falló: ${resp['error']}');
        }
      }
      
      debugPrint('⚠️ Ningún endpoint funcionó para userId: $userId');
      throw Exception('Recurso no encontrado');
    } catch (e) {
      debugPrint('❌ Error al obtener cliente: $e');
      throw Exception('Error al obtener el cliente: ${e.toString().split('\n').first}');
    }
  }
}
