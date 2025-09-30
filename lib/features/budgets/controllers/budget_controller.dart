import 'package:flutter/material.dart';
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
      print('🔄 BudgetController: Iniciando carga de clientes...');
      
      List<Map<String, dynamic>> fetchedCustomers =
          await budgetRemoteDataSource.getCustomers();
      
      print('✅ BudgetController: ${fetchedCustomers.length} clientes obtenidos');
      if (fetchedCustomers.isNotEmpty) {
        print('📋 Primeros clientes: ${fetchedCustomers.take(3).map((c) => '${c['name']} (${c['_id']})').join(', ')}');
      }
      
      customers.assignAll(fetchedCustomers);
      print('🔄 BudgetController: Lista de clientes actualizada. Total en memoria: ${customers.length}');
    } catch (e) {
      print('❌ BudgetController: Error al obtener clientes: $e');
      Get.snackbar("Error", "No se pudo obtener la lista de clientes: $e");
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

      final result = await budgetRemoteDataSource.createBudget(budget);
      debugPrint('💾 Resultado de creación de presupuesto: $result');
      
      if (result['success'] == true) {
        // Éxito - Mostrar snackbar verde
        Get.snackbar(
          "Éxito", 
          "Presupuesto creado correctamente",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
        );
        return true;
      } else {
        // Error - Mostrar diálogo
        String errorTitle = "Error al crear presupuesto";
        String errorMsg = "No se pudo crear el presupuesto";
        String btnText = "Entendido";
        
        // Verificar si es un presupuesto duplicado
        if (result['isDuplicate'] == true || 
            result['error']?.toString().toLowerCase().contains('duplicado') == true || 
            result['error']?.toString().toLowerCase().contains('duplicate') == true) {
          errorTitle = "Presupuesto duplicado";
          errorMsg = "Ya existe un presupuesto para esta obra y cliente. No se pueden crear duplicados.";
        }
        // Verificar errores de servidor (incluyendo error 500)
        else if (result['statusCode'] == 500 || result['error']?.toString().toLowerCase().contains('server') == true) {
          errorTitle = "Error del servidor";
          errorMsg = "El servidor no pudo procesar su solicitud. Esto puede deberse a que:"
                    "\n\n1. Ya existe un presupuesto similar"
                    "\n2. El servidor está experimentando problemas temporales"
                    "\n\nPor favor, verifique si ya existe un presupuesto para este cliente y obra, o inténtelo más tarde.";
        }
        // Otros errores específicos
        else if (result['error']?.toString().toLowerCase().contains('customerid') == true) {
          errorTitle = "Cliente no válido";
          errorMsg = "El cliente seleccionado no es válido o no existe.";
        }
        // HTTP 401 ahora se maneja globalmente en HttpHelper
        // Error genérico pero con mensaje
        else if (result['error'] != null) {
          errorMsg = result['error'].toString();
        }
        
        // Mostrar diálogo en lugar de snackbar
        await Get.dialog(
          AlertDialog(
            title: Text(errorTitle),
            content: Text(errorMsg),
            actions: [
              TextButton(
                child: Text(btnText),
                onPressed: () => Get.back(),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          ),
          barrierDismissible: false,
        );
        
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error al crear presupuesto: $e");
      
      // Mostrar diálogo para excepciones inesperadas
      await Get.dialog(
        AlertDialog(
          title: const Text("Error inesperado"),
          content: const Text(
            "Ha ocurrido un error inesperado al crear el presupuesto. "
            "Por favor, verifique su conexión a internet e inténtelo nuevamente más tarde."
          ),
          actions: [
            TextButton(
              child: const Text("Aceptar"),
              onPressed: () => Get.back(),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        barrierDismissible: false,
      );
      
      return false;
    } finally {
      isLoading(false);
    }
  }
}
