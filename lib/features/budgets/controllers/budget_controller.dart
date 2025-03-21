import 'package:get/get.dart';
import 'package:crm_app_dv/features/budgets/data/budget_data_source.dart';
import 'package:crm_app_dv/models/budget_model.dart';

class BudgetController extends GetxController {
  final BudgetRemoteDataSource budgetRemoteDataSource;
  BudgetController({required this.budgetRemoteDataSource});

  var isLoading = false.obs;
  var customers = <Map<String, dynamic>>[].obs;
  var works = <Map<String, dynamic>>[].obs;
  var budgets = <BudgetModel>[].obs;

  var selectedCustomerId = RxnString();
  var selectedWorkId = RxnString();


  final selectedMaterials = <String>[].obs;
  final selectedApprovals = <String>[].obs;
  final selectedSubcontractors = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

 
  Future<void> fetchCustomers() async {
    try {
      isLoading(true);
      List<Map<String, dynamic>> fetchedCustomers =
          await budgetRemoteDataSource.getCustomers();
      customers.assignAll(fetchedCustomers);
    } catch (e) {
      Get.snackbar("Error", "No se pudo obtener la lista de clientes");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchWorksByCustomer(String customerId) async {
    try {
      isLoading(true);
      works.value = await budgetRemoteDataSource.getWorksByCustomer(customerId);
      print("✅ Obras obtenidas: ${works.length}");
    } catch (e) {
      print("❌ Error al obtener obras: $e");
      Get.snackbar("Error", "No se pudieron obtener las obras del cliente");
    } finally {
      isLoading(false);
    }
  }


  Future<void> fetchBudgetsByCustomer(String customerId) async {
    try {
      isLoading(true);
      final fetchedBudgets =
          await budgetRemoteDataSource.getBudgetsByCustomer(customerId);
      budgets.assignAll(fetchedBudgets);
      print("✅ Presupuestos obtenidos: ${budgets.length}");
    } catch (e) {
      print("❌ Error al obtener presupuestos: $e");
    } finally {
      isLoading(false);
    }
  }

  
  Future<bool> createBudget(BudgetModel budget) async {
    try {
      isLoading(true);

      bool success = await budgetRemoteDataSource.createBudget(budget);

      if (success) {
        Get.snackbar("Éxito", "Presupuesto creado correctamente");
        return true;
      } else {
        Get.snackbar("Error", "No se pudo crear el presupuesto.");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Error inesperado: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }
}
