import 'dart:convert';
import 'package:crm_app_dv/models/budget_model.dart';
import 'package:crm_app_dv/models/work_model.dart';
import 'package:http/http.dart' as http;

class BudgetDataSource {
  final String baseUrl = "http://10.0.2.2:8080";

  Future<List<BudgetModel>> getAllBudgets() async {
    final response = await http.get(Uri.parse("$baseUrl/budget"));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((budget) => BudgetModel.fromJson(budget)).toList();
    } else {
      throw Exception("Error al obtener los presupuestos");
    }
  }

 Future<List<WorkModel>> getWorksByCustomer(String customerId) async {
  final response = await http.get(Uri.parse("$baseUrl/works?customerId=$customerId"));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    if (data.isEmpty) {
      throw Exception("No hay trabajos asociados a este cliente.");
    }
    return data.map((work) => WorkModel.fromJson(work)).toList();
  } else {
    throw Exception("Error al obtener los trabajos del cliente: ${response.statusCode}");
  }
}

Future<List<dynamic>> getCustomers() async {
  final response = await http.get(Uri.parse("$baseUrl/customers"));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data;
  } else {
    throw Exception("Error al obtener la lista de clientes");
  }
}



  Future<void> createBudget(BudgetModel budget) async {
    final response = await http.post(
      Uri.parse("$baseUrl/budget"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(budget.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al crear el presupuesto");
    }
  }
}
