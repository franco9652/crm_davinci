import 'dart:convert';
import 'package:crm_app_dv/models/budget_model.dart';
import 'package:http/http.dart' as http;

class BudgetDataSource {
  final String baseUrl = "http://localhost:8080";

  Future<List<BudgetModel>> getAllBudgets() async {
    final response = await http.get(Uri.parse("$baseUrl/budget"));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((budget) => BudgetModel.fromJson(budget)).toList();
    } else {
      throw Exception("Error al obtener los presupuestos");
    }
  }

  Future<BudgetModel> createBudget(BudgetModel budget) async {
    final response = await http.post(
      Uri.parse("$baseUrl/budget"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(budget.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return BudgetModel.fromJson(data['newBudget']);
    } else {
      throw Exception("Error al crear el presupuesto");
    }
  }
}
