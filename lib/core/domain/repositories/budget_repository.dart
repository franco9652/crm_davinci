import 'package:crm_app_dv/features/budgets/data/budget_data_source.dart';
import 'package:crm_app_dv/models/budget_model.dart';
import 'package:crm_app_dv/models/work_model.dart';

class BudgetRepository {
  final BudgetDataSource dataSource;

  BudgetRepository(this.dataSource);

  Future<List<BudgetModel>> getAllBudgets() {
    return dataSource.getAllBudgets();
  }

  Future<List<WorkModel>> getWorksByCustomer(String customerId) {
    return dataSource.getWorksByCustomer(customerId);
  }
  
  Future<List<dynamic>> getCustomers() async {
  return await dataSource.getCustomers(); // Asegúrate de que `getCustomers` exista en el DataSource
}


  Future<void> createBudget(BudgetModel budget) {
    return dataSource.createBudget(budget);
  }
}
