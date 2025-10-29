import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:crm_app_dv/core/contants/app_constants.dart';
import 'package:crm_app_dv/models/budget_model.dart';
import 'package:crm_app_dv/core/utils/http_helper.dart';

class BudgetRemoteDataSource {
  final http.Client client;

  BudgetRemoteDataSource(this.client);


  Future<List<Map<String, dynamic>>> getCustomers() async {
    try {
      debugPrint('🔄 Solicitando TODOS los clientes desde BudgetRemoteDataSource');
      
      List<Map<String, dynamic>> allCustomers = [];
      int page = 1;
      int totalPages = 1;
      
      
      do {
        debugPrint('🔄 Solicitando página $page de clientes...');
        final response = await HttpHelper.get('${AppConstants.baseUrl}/customers?page=$page');
        
        if (response['success'] != true) {
          debugPrint('❌ Error al obtener clientes página $page: ${response['error']}');
          throw Exception(response['error'] ?? 'Error al obtener la lista de clientes');
        }
        
        final dynamic jsonResponse = response['data'];
        List<dynamic> customersData = [];
        
       
        if (jsonResponse is Map && jsonResponse.containsKey('customers')) {
          customersData = jsonResponse['customers'];
          totalPages = jsonResponse['totalPages'] ?? 1;
          debugPrint('📋 Página $page de $totalPages - ${customersData.length} clientes');
        } else if (jsonResponse is List) {
          customersData = jsonResponse;
          debugPrint('📋 Página $page - ${customersData.length} clientes (formato lista)');
        }
        
      
        final pageCustomers = List<Map<String, dynamic>>.from(
          customersData.map((item) => Map<String, dynamic>.from(item))
        );
        allCustomers.addAll(pageCustomers);
        
        page++;
      } while (page <= totalPages);
      
      debugPrint('✅ Total de clientes obtenidos: ${allCustomers.length}');
      
      if (allCustomers.isEmpty) {
        debugPrint('⚠️ No se encontraron clientes en ninguna página');
      } else {
        debugPrint('📋 Primeros 3 clientes: ${allCustomers.take(3).map((c) => c['name']).join(', ')}');
      }
      
      return allCustomers;
    } catch (e) {
      debugPrint('❌ Error en getCustomers: $e');
      throw Exception('Error al obtener la lista de clientes: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getWorksByCustomer(String customerId) async {
    try {
      debugPrint('🔄 Solicitando obras del cliente ID: $customerId');
      final response = await HttpHelper.get('${AppConstants.baseUrl}/worksbycustomerid/$customerId');
      
      if (response['success'] != true) {
        debugPrint('❌ Error al obtener obras: ${response['error']}');
        throw Exception(response['error'] ?? 'Error al obtener las obras del cliente');
      }
      
      final dynamic jsonResponse = response['data'];
      debugPrint('✅ Respuesta recibida tipo: ${jsonResponse.runtimeType}');
      
      
      if (jsonResponse is Map && jsonResponse.containsKey('works') && jsonResponse['works'] is List) {
        final works = jsonResponse['works'] as List;
        debugPrint('📋 Total de obras encontradas: ${works.length}');
        return List<Map<String, dynamic>>.from(works.map((item) => Map<String, dynamic>.from(item)));
      } else {
        debugPrint('⚠️ Formato de respuesta inválido: ${jsonResponse.runtimeType}');
        throw Exception("Formato de respuesta inválido: falta 'works' o no es una lista.");
      }
    } catch (e) {
      debugPrint('❌ Error en getWorksByCustomer: $e');
      throw Exception('Error al obtener las obras del cliente: ${e.toString()}');
    }
  }

  Future<List<BudgetModel>> getBudgetsByCustomer(String customerId) async {
    try {
      debugPrint('🔄 Solicitando presupuestos del cliente ID: $customerId');
      final response = await HttpHelper.get('${AppConstants.baseUrl}/budgetgetbyuser/$customerId');
      
      if (response['success'] != true) {
        debugPrint('❌ Error al obtener presupuestos: ${response['error']}');
        throw Exception(response['error'] ?? 'Error al obtener los presupuestos');
      }
      
      final dynamic jsonResponse = response['data'];
      debugPrint('✅ Respuesta recibida tipo: ${jsonResponse.runtimeType}');
      
      
      if (jsonResponse is Map && jsonResponse.containsKey('budgets') && jsonResponse['budgets'] is List) {
        final budgetsJson = jsonResponse['budgets'] as List;
        debugPrint('📋 Total de presupuestos encontrados: ${budgetsJson.length}');
        
        
        List<BudgetModel> budgets = [];
        int errorCount = 0;
        
        for (var i = 0; i < budgetsJson.length; i++) {
          try {
            budgets.add(BudgetModel.fromJson(budgetsJson[i]));
          } catch (e) {
            debugPrint('❌ Error al convertir presupuesto #$i: $e');
            errorCount++;
          }
        }
        
        if (errorCount > 0) {
          debugPrint('⚠️ $errorCount presupuestos no pudieron ser procesados');
        }
        
        return budgets;
      } else {
        debugPrint('⚠️ Formato de respuesta inválido: ${jsonResponse.runtimeType}');
        return <BudgetModel>[];
      }
    } catch (e) {
      debugPrint('❌ Error en getBudgetsByCustomer: $e');
      throw Exception('Error al obtener los presupuestos: ${e.toString()}');
    }
  }

Future<Map<String, dynamic>> createBudget(BudgetModel budget) async {
  try {
   
    Map<String, dynamic> requestBody = {
      "customerId": budget.customerId,
      "items": [
        {
          "descripcion": budget.projectType,
          "cantidad": 1,
          "precioUnitario": budget.estimatedBudget
        }
      ],
      "total": budget.estimatedBudget,
      "estado": budget.status
    };
    
   
    if (budget.workId != null && budget.workId!.isNotEmpty) {
      requestBody["workId"] = budget.workId;
    }

    debugPrint('🔄 Creando nuevo presupuesto para cliente ID: ${budget.customerId}');
    debugPrint('💾 Datos del presupuesto: ${jsonEncode(requestBody)}');
    
    final response = await HttpHelper.post(
      '${AppConstants.baseUrl}/budget',
      requestBody
    );

    if (response['success'] != true) {
      final errorMsg = response['error'] ?? 'Error desconocido al crear el presupuesto';
      debugPrint('❌ Error al crear presupuesto: $errorMsg');
      
      
      if (errorMsg.toLowerCase().contains('duplicado') || 
          errorMsg.toLowerCase().contains('duplicate') ||
          (response.containsKey('data') && 
           response['data'] is Map &&
           response['data'].toString().toLowerCase().contains('duplicado'))) {
        return <String, dynamic>{
          'success': false,
          'error': 'Ya existe un presupuesto para este cliente y obra',
          'statusCode': 409,
          'isDuplicate': true
        };
      }
      
      return <String, dynamic>{
        'success': false,
        'error': errorMsg,
        'statusCode': response['statusCode'] ?? 400
      };
    }
    
    debugPrint('✅ Presupuesto creado correctamente');
    return <String, dynamic>{
      'success': true,
      'message': 'Presupuesto creado correctamente',
      'statusCode': 200,
      'data': response['data']
    };
  } catch (e) {
    debugPrint('❌ Error al crear presupuesto: $e');
    return <String, dynamic>{
      'success': false,
      'error': 'Error al crear el presupuesto: ${e.toString().split('\n').first}',
      'statusCode': 500
    };
  }
}

}
