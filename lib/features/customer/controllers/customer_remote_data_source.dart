import 'dart:convert';
import 'package:crm_app_dv/core/constants/app_constants.dart';
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
      
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      
      
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
     
      final url = '${AppConstants.baseUrl}/customers?page=$page';
      debugPrint('🔄 Solicitando clientes a: $url');
      
      
      final response = await HttpHelper.get(url);
      
      
      if (response['success'] != true) {
        debugPrint('❌ Error en la respuesta: ${response['error']}');
        throw Exception(response['error'] ?? 'Error al obtener clientes');
      }
      
     
      final dynamic jsonResponse = response['data'];
      debugPrint('✅ Respuesta recibida tipo: ${jsonResponse.runtimeType}');
      
      
      if (jsonResponse is Map && jsonResponse.containsKey('customers')) {
        final customersData = jsonResponse['customers'] as List<dynamic>;
        final totalPages = jsonResponse['totalPages'] as int? ?? 1;
        final currentPage = jsonResponse['page'] as int? ?? 1;
        
        debugPrint('📋 Página $currentPage de $totalPages - ${customersData.length} clientes recibidos');
        
       
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
     
      debugPrint('❌❌❌ ERROR AL OBTENER CLIENTES:');
      debugPrint('💥 Excepción: $e');
      debugPrint('📍 StackTrace: \n$stackTrace');
      
      
      String errorMessage;
      
      
      if (e.toString().contains('timeout')) {
        errorMessage = 'La conexión al servidor ha tardado demasiado. Por favor, inténtelo nuevamente.';
      }
      
      else if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused')) {
        errorMessage = 'No se pudo conectar al servidor. Verifique su conexión a internet.';
      }
      
      else {
        errorMessage = 'No se pudieron cargar los clientes: ${e.toString().split('\n').first}';
      }
      
    
      return <String, dynamic>{
        'success': false,
        'error': errorMessage,
        'customers': <CustomerModel>[],
        'totalPages': 1
      };
    }
  }

  Future<List<WorkModel>> getWorksByUserId(String customerId) async {
    print("Buscando obras para customerId: $customerId");
    final response = await client.get(
      Uri.parse('${AppConstants.baseUrl}/workgetbycustomerid/$customerId'),
      headers: {'Content-Type': 'application/json'},
    );
    print("Response status: ${response.statusCode}");
    
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print("✅ Obras encontradas: ${jsonResponse['works']?.length ?? 0}");
      return (jsonResponse['works'] as List)
          .map((data) => WorkModel.fromJson(data))
          .toList();
    } else if (response.statusCode == 404) {
      final jsonResponse = json.decode(response.body);
      print("❌ 404 - Backend dice: ${jsonResponse['message']}");
      print("❌ CustomerIdReceived: ${jsonResponse['customerIdReceived']}");
      return []; 
    } else {
      print("❌ Error ${response.statusCode}: ${response.body}");
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
      
      String? token;
      try {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('auth_token');
      } catch (_) {}

      final headers = <String, String>{
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      
      print('🔍 Analizando customerId: $userId');
      
     
      final endpoints = [
        '${AppConstants.baseUrl}/getcustomersbyid/$userId',
        '${AppConstants.baseUrl}/customers/$userId', 
        '${AppConstants.baseUrl}/customer/$userId',
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
            
            if (data['customer'] is List && (data['customer'] as List).isNotEmpty) {
              found = Map<String, dynamic>.from((data['customer'] as List).first);
            }
            
            else if (data['customer'] is Map) {
              found = Map<String, dynamic>.from(data['customer'] as Map);
            }
            
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

  Future<CustomerModel> updateCustomer({
    required String customerId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      debugPrint('🔄 Actualizando cliente: $customerId');
      debugPrint('📤 Datos enviados al backend: $updateData');
      
      final response = await HttpHelper.put(
        '${AppConstants.baseUrl}/updateCustomer/$customerId',
        updateData,
      );
      
      if (response['success'] == true) {
        final customerData = response['data'] as Map<String, dynamic>;
        debugPrint('📥 Datos recibidos del backend: $customerData');
        final updatedCustomer = CustomerModel.fromJson(customerData);
        debugPrint('✅ Cliente actualizado: ${updatedCustomer.name} ${updatedCustomer.secondName}');
        return updatedCustomer;
      } else {
        final errorMsg = response['error'] ?? 'Error desconocido al actualizar cliente';
        debugPrint('❌ Error actualizando cliente: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('❌ Excepción al actualizar cliente: $e');
      throw Exception('Error al actualizar el cliente: ${e.toString()}');
    }
  }


  Future<void> deleteCustomer(String customerId) async {
    try {
      debugPrint('🗑️ Eliminando cliente: $customerId');
      
      final response = await HttpHelper.delete(
        '${AppConstants.baseUrl}/deleteCustomer/$customerId',
      );
      
      debugPrint('📡 Respuesta del servidor: $response');
      
     
      if (response['success'] == true || 
          response.containsKey('message') && response['message'].toString().contains('eliminado correctamente')) {
        debugPrint('✅ Cliente eliminado correctamente');
        return;
      } else {
        final errorMsg = response['error'] ?? response['message'] ?? 'Error desconocido al eliminar cliente';
        debugPrint('❌ Error eliminando cliente: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('❌ Excepción al eliminar cliente: $e');
      throw Exception('Error al eliminar el cliente: ${e.toString()}');
    }
  }
}
