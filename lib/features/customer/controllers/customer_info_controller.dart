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
      final customerData = await customerRepository.getCustomerById(userId);
      
      // Convertir Map a CustomerModel
      if (customerData.isNotEmpty) {
        customer.value = CustomerModel.fromJson(customerData);
        
        // 🔹 Usar el ID del cliente para obtener sus trabajos y presupuestos
        final customerId = customerData['_id'] ?? customerData['id'] ?? userId;
        if (customerId != null && customerId.toString().isNotEmpty) {
          fetchWorksByCustomer(customerId.toString());
          fetchBudgetsByCustomer(customerId.toString());
        }
      }
    } catch (e) {
      Get.snackbar("Error", "No se pudo cargar la información del cliente: $e");
    } finally {
      isLoadingCustomer(false);
      isLoadingWorks(false);
      isLoadingBudgets(false);
    }
  }

  Future<void> fetchWorksByCustomer(String customerId) async {
    try {
      isLoadingWorks(true);
      
      print("Obteniendo trabajos para customerId: $customerId");

      if (customerId.isNotEmpty) {
        final fetchedWorks = await customerRepository.getWorksByUserId(customerId);
        print("Trabajos obtenidos: ${fetchedWorks.length}");
        userWorks.assignAll(fetchedWorks);
      } else {
        print("Error: El customerId está vacío.");
      }
    } catch (e) {
      Get.snackbar("Error", "No se pudieron cargar los trabajos del cliente: $e");
      print("Error fetchWorksByCustomer: $e");
    } finally {
      isLoadingWorks(false);
    }
  }


  /// Obtener presupuestos del cliente
  Future<void> fetchBudgetsByCustomer(String customerId) async {
    try {
      isLoadingBudgets(true);
      
      print("Obteniendo presupuestos para customerId: $customerId");

      if (customerId.isNotEmpty) {
        final fetchedBudgets = await customerRepository.getBudgetsByCustomer(customerId);
        print("Presupuestos obtenidos: ${fetchedBudgets.length}");
        budgets.assignAll(fetchedBudgets);
      } else {
        print("Error: El customerId está vacío.");
      }
    } catch (e) {
      Get.snackbar("Error", "No se pudieron cargar los presupuestos del cliente: $e");
      print("Error fetchBudgetsByCustomer: $e");
    } finally {
      isLoadingBudgets(false);
    }
  }
}
