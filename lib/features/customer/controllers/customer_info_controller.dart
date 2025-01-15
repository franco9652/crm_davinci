import 'package:crm_app_dv/core/domain/repositories/customer_repository.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:crm_app_dv/models/work_model.dart';
import 'package:crm_app_dv/models/budget_model.dart';
import 'package:get/get.dart';

class CustomerInfoController extends GetxController {
  final CustomerRepository customerRepository;

  // Constructor que recibe el repositorio
  CustomerInfoController({required this.customerRepository});

  var customer = Rxn<CustomerModel>(); // Información del cliente
  var works = <WorkModel>[].obs; // Lista de trabajos
  var budgets = <BudgetModel>[].obs; // Lista de presupuestos

  var isLoadingCustomer = false.obs; // Indicador de carga para el cliente
  var isLoadingWorks = false.obs; // Indicador de carga para los trabajos
  var isLoadingBudgets = false.obs; // Indicador de carga para los presupuestos

  // Método para obtener la información del cliente
 Future<void> fetchCustomerInfo(String userId) async {
  if (userId.isEmpty) {
    Get.snackbar("Error", "El ID del cliente no es válido");
    return;
  }

  try {
    isLoadingCustomer(true);
    isLoadingWorks(true);
    isLoadingBudgets(true);

    print("UserId recibido: $userId");

    // Obtener los detalles del cliente
    final fetchedCustomer = await customerRepository.getCustomerById(userId);
    customer.value = fetchedCustomer;

    // Obtener trabajos asociados
    /* final fetchedWorks = await customerRepository.getWorksByCustomer(userId);
    works.assignAll(fetchedWorks); */

    // Obtener presupuestos asociados
   /*  final fetchedBudgets = await customerRepository.getBudgetsByCustomer(userId);
    budgets.assignAll(fetchedBudgets); */
  } catch (e) {
    Get.snackbar("Error", "No se pudo cargar la información del cliente: $e");
  } finally {
    isLoadingCustomer(false);
    isLoadingWorks(false);
    isLoadingBudgets(false);
  }
}

}
