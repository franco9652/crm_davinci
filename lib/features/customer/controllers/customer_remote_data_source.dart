import 'dart:convert';

import 'package:crm_app_dv/core/contants/app_constants.dart';
import 'package:crm_app_dv/core/utils/http_helper.dart';
import 'package:crm_app_dv/models/budget_model.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:crm_app_dv/models/work_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class CustomerRemoteDataSource {
  final http.Client client;

  CustomerRemoteDataSource(this.client);

  Future<void> createCustomer(CustomerModel customer) async {
    final response = await client.post(
      Uri.parse('${AppConstants.baseUrl}/customerCreate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(customer.toJson()),
    );

    final responseBody = jsonDecode(response.body);

    
    if (response.statusCode == 200 || response.statusCode == 201) {
      
      return;
    } else if (response.statusCode == 400 || response.statusCode == 409) {
      
      throw Exception(responseBody['message'] ?? 'Error desconocido');
    } else {
      
      if (responseBody['message']?.contains('Cliente creado') == true) {
        
        return;
      }
      
      throw Exception('Error al dar de alta un cliente: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getAllCustomers(int page) async {
    const int limit = 5; // Máximo de clientes por página
    try {
      // Usamos HttpHelper para tener manejo centralizado y consistente
      debugPrint('🔄 Solicitando clientes a: ${AppConstants.baseUrl}/customers');
      
      // Hacemos la solicitud a través del helper
      final response = await HttpHelper.get('${AppConstants.baseUrl}/customers');
      
      // Verificar si la solicitud fue exitosa
      if (response['success'] != true) {
        debugPrint('❌ Error en la respuesta: ${response['error']}');
        throw Exception(response['error'] ?? 'Error al obtener clientes');
      }
      
      // El helper ya maneja errores HTTP básicos, aquí procesamos la respuesta
      final dynamic jsonResponse = response['data'];
      debugPrint('✅ Respuesta recibida tipo: ${jsonResponse.runtimeType}');
      
      // Adaptamos la respuesta al formato esperado por la aplicación
      List<dynamic> customersData = [];
      
      if (jsonResponse is List) {
        // La API devuelve directamente una lista de clientes
        debugPrint('📋 Formato de respuesta: Lista directa');
        customersData = jsonResponse;
      } else if (jsonResponse is Map) {
        if (jsonResponse.containsKey('customers')) {
          // La API devuelve un objeto con una propiedad 'customers'
          debugPrint('📋 Formato de respuesta: Objeto con propiedad "customers"');
          customersData = jsonResponse['customers'];
        } else if (jsonResponse.containsKey('data')) {
          // Formato alternativo con propiedad 'data'
          debugPrint('📋 Formato de respuesta: Objeto con propiedad "data"');
          final dataContent = jsonResponse['data'];
          if (dataContent is List) {
            customersData = dataContent;
          } else if (dataContent is Map && dataContent.containsKey('customers')) {
            customersData = dataContent['customers'];
          }
        } else {
          // Último recurso: buscar la primera clave que contenga una lista
          debugPrint('⚠️ Buscando lista de clientes en cualquier propiedad');
          for (final key in jsonResponse.keys) {
            if (jsonResponse[key] is List && (jsonResponse[key] as List).isNotEmpty) {
              debugPrint('🔎 Encontrada posible lista de clientes en la propiedad "$key"');
              customersData = jsonResponse[key];
              break;
            }
          }
        }
      }
      
      if (customersData.isEmpty) {
        debugPrint('⚠️ No se encontraron clientes en la respuesta');
        return <String, dynamic>{'customers': <CustomerModel>[], 'totalPages': 1};
      }
      
      debugPrint('📋 Cantidad de clientes recibidos: ${customersData.length}');
      
      // Convertimos a modelo con diagnóstico detallado
      List<CustomerModel> allCustomers = [];
      int errorCount = 0;
      
      for (var i = 0; i < customersData.length; i++) {
        try {
          final data = customersData[i];
          // Verificamos que el cliente tenga los campos mínimos necesarios
          if (data is Map && data.containsKey('name')) {
            // Convertir explícitamente a Map<String, dynamic> para evitar errores de tipado
            final Map<String, dynamic> customerData = Map<String, dynamic>.from(data);
            allCustomers.add(CustomerModel.fromJson(customerData));
          } else {
            debugPrint('⚠️ Cliente #$i no tiene campos mínimos: $data');
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
      
      debugPrint('✅ Clientes convertidos exitosamente: ${allCustomers.length}');
      
      // Si no hay clientes después de todo el procesamiento
      if (allCustomers.isEmpty) {
        debugPrint('⚠️ No quedaron clientes después del procesamiento');
        return <String, dynamic>{'customers': <CustomerModel>[], 'totalPages': 1};
      }
      
      // Implementamos paginación client-side
      int startIndex = (page - 1) * limit;
      int endIndex = startIndex + limit;
      
      // Validamos índices
      if (startIndex >= allCustomers.length) {
        startIndex = 0;
        debugPrint('⚠️ Índice de inicio fuera de rango, reiniciando a 0');
      }
      
      if (endIndex > allCustomers.length) {
        endIndex = allCustomers.length;
      }
      
      List<CustomerModel> pagedCustomers = [];
      if (startIndex < allCustomers.length) {
        pagedCustomers = allCustomers.sublist(startIndex, endIndex);
        debugPrint('📄 Página $page: mostrando clientes $startIndex-$endIndex de ${allCustomers.length}');
      }
      
      int totalPages = (allCustomers.length / limit).ceil();
      if (totalPages < 1) totalPages = 1;

      return <String, dynamic>{
        'customers': pagedCustomers, 
        'totalPages': totalPages,
        'totalCount': allCustomers.length
      };
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
      
      final response = await HttpHelper.get(
        '${AppConstants.baseUrl}/getcustomersbyid/$userId'
      );
      
      if (response['success'] != true) {
        debugPrint('❌ Error al obtener cliente: ${response['error']}');
        throw Exception(response['error'] ?? 'Error al obtener el cliente');
      }
      
      final responseData = response['data'];
      
      if (responseData is Map && responseData.containsKey('customer')) {
        final customerList = responseData['customer'];
        
        if (customerList is List && customerList.isNotEmpty) {
          debugPrint('✅ Cliente obtenido correctamente');
          return Map<String, dynamic>.from(customerList[0]);
        }
      }
      
      debugPrint('⚠️ Formato de respuesta inesperado');
      throw Exception('No se encontró el cliente solicitado');
    } catch (e) {
      debugPrint('❌ Error al obtener cliente: $e');
      throw Exception('Error al obtener el cliente: ${e.toString().split('\n').first}');
    }
  }
}
