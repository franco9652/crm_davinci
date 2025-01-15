import 'package:crm_app_dv/models/customer_model.dart';
import 'package:crm_app_dv/models/work_model.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/models/budget_model.dart';
import 'package:crm_app_dv/core/domain/repositories/budget_repository.dart';

class BudgetController extends GetxController {
  final BudgetRepository repository;

  BudgetController(this.repository);

  // Observables
  var customers = <CustomerModel>[].obs;

var worksForCustomer = <WorkModel>[].obs;

  var selectedCustomerId = ''.obs;
  var selectedWorkId = ''.obs;
  var isLoadingCustomers = false.obs;
  var isLoadingWorks = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

Future<void> fetchCustomers() async {
  try {
    isLoadingCustomers(true);
    final fetchedCustomers = await repository.getCustomers(); // Obtener clientes desde el repositorio
    customers.assignAll(fetchedCustomers.map((data) => CustomerModel.fromJson(data)).toList());
  } catch (e) {
    Get.snackbar("Error", "No se pudieron cargar los clientes: $e");
  } finally {
    isLoadingCustomers(false);
  }
}



 Future<void> fetchWorksForCustomer(String customerId) async {
  try {
    isLoadingWorks(true);
    final fetchedWorks = await repository.getWorksByCustomer(customerId);
    worksForCustomer.assignAll(fetchedWorks); // Asigna directamente si fetchedWorks ya contiene WorkModel
  } catch (e) {
    Get.snackbar("Error", "No se pudieron cargar los trabajos del cliente: $e");
  } finally {
    isLoadingWorks(false);
  }
}



  Future<void> createBudget(BudgetModel budget) async {
    try {
      await repository.createBudget(budget);
      Get.snackbar("Éxito", "Presupuesto creado correctamente");
    } catch (e) {
      Get.snackbar("Error", "No se pudo crear el presupuesto: $e");
    }
  }
}
