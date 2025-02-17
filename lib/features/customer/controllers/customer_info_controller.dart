import 'package:crm_app_dv/core/domain/repositories/customer_repository.dart';
import 'package:crm_app_dv/core/domain/repositories/works_repository.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:crm_app_dv/models/work_model.dart';
import 'package:crm_app_dv/models/budget_model.dart';
import 'package:get/get.dart';

class CustomerInfoController extends GetxController {
  final CustomerRepository customerRepository;

  // Constructor que recibe el repositorio
  CustomerInfoController({required this.customerRepository});

  var customer = Rxn<CustomerModel>(); // Información del cliente
  var userWorks = <WorkModel>[].obs; // Lista de trabajos
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

      // 🔹 Obtener el cliente usando su `userId`
      final fetchedCustomer = await customerRepository.getCustomerById(userId);
      customer.value = fetchedCustomer;

      // 🔹 Ahora usamos el `_id` del cliente para obtener sus trabajos
      if (fetchedCustomer != null && fetchedCustomer.userId != null) {
        fetchWorksByCustomer(fetchedCustomer.userId!);
      }
    } catch (e) {
      Get.snackbar("Error", "No se pudo cargar la información del cliente: $e");
    } finally {
      isLoadingCustomer(false);
      isLoadingWorks(false);
      isLoadingBudgets(false);
    }
  }

  Future<void> fetchWorksByCustomer(String userId) async {
  try {
    isLoadingWorks(true);
    
    // Obtener el customer primero para acceder al _id
    final fetchedCustomer = await customerRepository.getCustomerById(userId);

    if (fetchedCustomer != null) {
      final customerId = fetchedCustomer.id ?? fetchedCustomer.userId; // Asegurarnos de usar _id
      print("Customer ID correcto (_id en MongoDB): $customerId");

      if (customerId != null && customerId.isNotEmpty) {
        final fetchedWorks = await Get.find<WorkRepository>().getWorksByUserId(customerId);
         print("Trabajos obtenidos: $fetchedWorks");
        userWorks.assignAll(fetchedWorks);
      } else {
        print("Error: El customerId es nulo o vacío.");
      }
    } else {
      print("Error: No se encontró el cliente.");
    }
  } catch (e) {
    Get.snackbar("Error", "No se pudieron cargar los trabajos del cliente: $e");
    print(e);
  } finally {
    isLoadingWorks(false);
  }
}


  Future<void> fetchWorksByUser(String userId) async {
    try {
      final fetchedWorks =
          await Get.find<WorkRepository>().getWorksByUserId(userId);
      userWorks.value = fetchedWorks;
    } catch (e) {
      Get.snackbar(
          "Error", "No se pudieron cargar los trabajos del cliente: $e");
    }
  }
}
