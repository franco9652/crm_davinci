import 'package:crm_app_dv/features/budgets/data/budget_data_source.dart';
import 'package:crm_app_dv/models/budget_model.dart';

class BudgetRepository {
  final BudgetRemoteDataSource dataSource;

  BudgetRepository(this.dataSource);

 
  Future<List<Map<String, dynamic>>> getCustomers() async {
    return await dataSource.getCustomers();
  }

 
  Future<List<Map<String, dynamic>>> getWorksByCustomer(String customerId) async {
    return await dataSource.getWorksByCustomer(customerId);
  }


  Future<List<BudgetModel>> getBudgetsByCustomer(String customerId) async {
    return await dataSource.getBudgetsByCustomer(customerId);
  }


  Future<void> createBudget(BudgetModel budget) {
  final budgetData = budget.toJson();
  
  
  if (budgetData['workId'] == null || budgetData['workId'].isEmpty) {
    budgetData.remove('workId');
  }

  return dataSource.createBudget(BudgetModel.fromJson(budgetData));
}

}
