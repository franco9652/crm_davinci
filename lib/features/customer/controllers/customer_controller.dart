import 'package:crm_app_dv/core/domain/repositories/customer_repository.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final CustomerRepository repository;

  HomeController({required this.repository});

  final customers = <CustomerModel>[].obs; // Clientes de la página actual
  final allCustomers = <CustomerModel>[].obs; // TODOS los clientes (para dropdowns)
  final isLoading = false.obs; // Indicador de carga
  final isLoadingAll = false.obs; // Indicador de carga para todos los clientes
  final currentPage = 1.obs; // Página actual
  final totalPages = 1.obs; // Total de páginas
  final noClientMessage = "No hay clientes disponibles".obs;
  final isCreating = false.obs; // Indicador de alta de cliente
  final searchQuery = ''.obs;
  final filteredCustomers = <CustomerModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    ever(searchQuery, (_) => filterCustomers());
    Future.delayed(Duration.zero, () {
      fetchCustomers();
    });
  }

  Future<void> fetchCustomers() async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final response = await repository.fetchCustomers(currentPage.value);
      
      // Verificar si hay un error en la respuesta
      if (response.containsKey('success') && response['success'] == false) {
        final errorMsg = response['error'] as String? ?? 'Error desconocido';
        noClientMessage.value = errorMsg;
        // Mostrar snackbar con el error para mejorar la UX
        Get.snackbar(
          'Error',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
        );
        return;
      }
      
      final fetchedCustomers = response['customers'] as List<CustomerModel>;
      final totalPagesFromApi = response['totalPages'] as int;
      final totalCount = response['totalCount'] as int? ?? fetchedCustomers.length;
      
      if (fetchedCustomers.isEmpty && totalCount == 0) {
        noClientMessage.value = "No hay clientes disponibles";
      } else {
        customers.value = fetchedCustomers; // Guardar clientes de la página actual
        totalPages.value = totalPagesFromApi; // Guardar total de páginas
      }
    } catch (e) {
      print('Error en el controlador al cargar clientes: $e');
      noClientMessage.value = "Error al cargar los clientes. Intente nuevamente.";
      // Mostrar snackbar con el error para mejorar la UX
      Get.snackbar(
        'Error',
        'Ocurrió un problema al cargar los clientes',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Método para cargar TODOS los clientes de todas las páginas (para dropdowns)
  Future<void> fetchAllCustomers() async {
    if (isLoadingAll.value) return;

    isLoadingAll.value = true;
    List<CustomerModel> allCustomersList = [];

    try {
      int page = 1;
      int totalPagesFromApi = 1;

      do {
        print(' Cargando página $page de clientes para dropdown...');
        final response = await repository.fetchCustomers(page);
        
        if (response.containsKey('success') && response['success'] == false) {
          print(' Error al cargar página $page: ${response['error']}');
          break;
        }
        
        final fetchedCustomers = response['customers'] as List<CustomerModel>;
        totalPagesFromApi = response['totalPages'] as int;
        
        allCustomersList.addAll(fetchedCustomers);
        print(' Página $page cargada: ${fetchedCustomers.length} clientes');
        
        page++;
      } while (page <= totalPagesFromApi);

      allCustomers.value = allCustomersList;
      print(' Total clientes cargados para dropdown: ${allCustomersList.length}');
      
    } catch (e) {
      print(' Error cargando todos los clientes: $e');
      Get.snackbar(
        'Error',
        'No se pudieron cargar todos los clientes: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    } finally {
      isLoadingAll.value = false;
    }
  }

  void filterCustomers() {
    if (searchQuery.value.isEmpty) {
      filteredCustomers.value = customers;
    } else {
      filteredCustomers.value = customers.where((customer) =>
        customer.name.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void goToPage(int page) {
    if (page < 1 || page > totalPages.value) return;
    currentPage.value = page;
    fetchCustomers();
  }

  Future<void> createCustomer({
    required String name,
    required String secondName,
    required String dni,
    required String cuit,
    required String cuil,
    required String address,
    required String workDirection,
    required String contactNumber,
    required String email,
    required String password,
  }) async {
    if (isCreating.value) return;

    isCreating.value = true;

    try {
      final newCustomer = CustomerModel(
        name: name,
        secondName: secondName,
        dni: dni,
        cuit: cuit,
        cuil: cuil,
        address: address,
        workDirection: workDirection,
        contactNumber: contactNumber,
        email: email,
        password: password,
        firstRegister: true,
        clienteActivo: true,
        worksActive: [],
        documents: [],
        createdAt: DateTime.now(),
        active: true,
      );

      await repository.createCustomer(newCustomer);

      // Mostrar diálogo de éxito
      Get.defaultDialog(
        title: "Éxito",
        middleText: "El cliente ha sido creado exitosamente.",
        textConfirm: "Aceptar",
        onConfirm: () async {
          Get.back(); // Cerrar el diálogo
          Get.back(); // Volver al HomePageCustomer
          
          // Resetear a la primera página y refrescar
          currentPage.value = 1;
          await fetchCustomers();
        },
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFFFF8329),
      );
    } catch (e) {
      // Manejar errores del backend
      if (e.toString().contains("El email ya está registrado")) {
        Get.defaultDialog(
          title: "Error",
          middleText: "El email proporcionado ya está registrado.",
          textConfirm: "Aceptar",
          onConfirm: () => Get.back(), // Cerrar el diálogo
          confirmTextColor: Colors.white,
          buttonColor: Colors.red,
        );
      } else {
        // Manejar errores inesperados
        Get.defaultDialog(
          title: "Error",
          middleText: "Hubo un problema al crear el cliente. Intente nuevamente.",
          textConfirm: "Aceptar",
          onConfirm: () => Get.back(), // Cerrar el diálogo
          confirmTextColor: Colors.white,
          buttonColor: Colors.red,
        );
      }
    } finally {
      isCreating.value = false;
    }
  }
}
