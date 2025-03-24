import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crm_app_dv/core/contants/app_constants.dart';
import 'package:crm_app_dv/models/budget_model.dart';

class BudgetRemoteDataSource {
  final http.Client client;

  BudgetRemoteDataSource(this.client);


  Future<List<Map<String, dynamic>>> getCustomers() async {
    final response = await client.get(
      Uri.parse('${AppConstants.baseUrl}/customers'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonResponse['customers']);
    } else {
      throw Exception('Error al obtener la lista de clientes');
    }
  }

  Future<List<Map<String, dynamic>>> getWorksByCustomer(
      String customerId) async {
    final response = await client.get(
      Uri.parse('${AppConstants.baseUrl}/worksbycustomerid/$customerId'),
      headers: {'Content-Type': 'application/json'},
    );

    print("🔹 Status Code: ${response.statusCode}");
    print("🔹 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('works') && jsonResponse['works'] is List) {
        return List<Map<String, dynamic>>.from(jsonResponse['works']);
      } else {
        throw Exception(
            "Formato de respuesta inválido: falta 'works' o no es una lista.");
      }
    } else {
      throw Exception(
          "Error al obtener las obras del cliente (Status ${response.statusCode}): ${response.body}");
    }
  }

  Future<List<BudgetModel>> getBudgetsByCustomer(String customerId) async {
    final response = await client.get(
      Uri.parse('${AppConstants.baseUrl}/budgetgetbyuser/$customerId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> budgetsJson = jsonResponse['budgets'];

      return budgetsJson.map((json) => BudgetModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los presupuestos');
    }
  }

Future<bool> createBudget(BudgetModel budget) async {
  final budgetData = budget.toJson();
  if (budgetData['workId'] == null || budgetData['workId'].isEmpty) {
    budgetData.remove('workId');
  }

  try {
    final response = await client.post(
      Uri.parse('${AppConstants.baseUrl}/budget'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(budgetData),
    );

    print("🔵 Respuesta del servidor: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print("❌ Error en la solicitud: $e");
    return false;
  }
}

}
