import 'dart:convert';

import 'package:crm_app_dv/core/contants/app_constants.dart';
import 'package:crm_app_dv/models/budget_model.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:crm_app_dv/models/work_model.dart';
import 'package:http/http.dart' as http;

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
    final response = await client.get(
      Uri.parse('${AppConstants.baseUrl}/customers?page=$page&limit=$limit'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      final totalPages = jsonResponse['totalPages'];

      List<CustomerModel> customers = (jsonResponse['customers'] as List)
          .map((data) => CustomerModel.fromJson(data))
          .toList();

      return {'customers': customers, 'totalPages': totalPages};
    } else {
      throw Exception('Error al obtener los clientes');
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
    final response = await client.get(
      Uri.parse('${AppConstants.baseUrl}/getcustomersbyid/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['customer'][0];
    } else {
      throw Exception('Error al obtener el cliente por ID');
    }
  }
}
