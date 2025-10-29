import 'package:crm_app_dv/core/domain/repositories/customer_repository.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:crm_app_dv/models/work_model.dart';
import 'package:crm_app_dv/models/budget_model.dart';
import 'package:get/get.dart';

class CustomerInfoController extends GetxController {
  final CustomerRepository customerRepository;

  
  CustomerInfoController({required this.customerRepository});

  var customer = Rxn<CustomerModel>(); 
  var userWorks = <WorkModel>[].obs; 
  var budgets = <BudgetModel>[].obs; 

  var isLoadingCustomer = false.obs; 
  var isLoadingWorks = false.obs; 
  var isLoadingBudgets = false.obs; 

  
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

      
      final customerData = await customerRepository.getCustomerById(userId);
      
      
      if (customerData.isNotEmpty) {
        customer.value = CustomerModel.fromJson(customerData);
        
        
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
