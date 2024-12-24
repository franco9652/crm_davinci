import 'package:crm_app_dv/core/domain/repositories/budget_repository.dart';
import 'package:crm_app_dv/models/budget_model.dart';
import 'package:get/get.dart';


class BudgetController extends GetxController {
  final BudgetRepository repository;

  BudgetController(this.repository);

  var budgets = <BudgetModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchAllBudgets();
    super.onInit();
  }

  void fetchAllBudgets() async {
    try {
      isLoading(true);
      budgets.value = await repository.getAllBudgets();
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los presupuestos');
    } finally {
      isLoading(false);
    }
  }

  void createBudget(BudgetModel budget) async {
    try {
      isLoading(true);
      await repository.createBudget(budget);
      fetchAllBudgets(); // Refresca la lista de presupuestos
      Get.snackbar('Éxito', 'Presupuesto creado correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo crear el presupuesto');
    } finally {
      isLoading(false);
    }
  }
}
