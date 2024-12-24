import 'package:crm_app_dv/features/budgets/data/budget_data_source.dart';
import 'package:crm_app_dv/models/budget_model.dart';


class BudgetRepository {
  final BudgetDataSource dataSource;

  BudgetRepository(this.dataSource);

  Future<List<BudgetModel>> getAllBudgets() async {
    return await dataSource.getAllBudgets();
  }

  Future<BudgetModel> createBudget(BudgetModel budget) async {
    return await dataSource.createBudget(budget);
  }
}
