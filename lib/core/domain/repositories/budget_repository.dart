import 'package:crm_app_dv/features/budgets/data/budget_data_source.dart';
import 'package:crm_app_dv/models/budget_model.dart';

class BudgetRepository {
  final BudgetRemoteDataSource dataSource;

  BudgetRepository(this.dataSource);

  // Obtener lista de clientes
  Future<List<Map<String, dynamic>>> getCustomers() async {
    return await dataSource.getCustomers();
  }

  // Obtener lista de obras por cliente
  Future<List<Map<String, dynamic>>> getWorksByCustomer(String customerId) async {
    return await dataSource.getWorksByCustomer(customerId);
  }

  // Obtener lista de presupuestos por cliente
  Future<List<BudgetModel>> getBudgetsByCustomer(String customerId) async {
    return await dataSource.getBudgetsByCustomer(customerId);
  }

  // Crear un presupuesto
  Future<void> createBudget(BudgetModel budget) {
  final budgetData = budget.toJson();
  
  // Si workId es nulo o vacío, lo eliminamos
  if (budgetData['workId'] == null || budgetData['workId'].isEmpty) {
    budgetData.remove('workId');
  }

  return dataSource.createBudget(BudgetModel.fromJson(budgetData));
}

}
