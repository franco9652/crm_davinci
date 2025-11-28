import 'package:crm_app_dv/core/domain/repositories/customer_repository.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final CustomerRepository repository;

  HomeController({required this.repository});

  final customers = <CustomerModel>[].obs; 
  final allCustomers = <CustomerModel>[].obs; 
  final isLoading = false.obs;
  final isLoadingAll = false.obs; 
  final currentPage = 1.obs; 
  final totalPages = 1.obs; 
  final noClientMessage = "No hay clientes disponibles".obs;
  final isCreating = false.obs; 
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
      
      if (response.containsKey('success') && response['success'] == false) {
        final errorMsg = response['error'] as String? ?? 'Error desconocido';
        noClientMessage.value = errorMsg;
        
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
        customers.value = fetchedCustomers; 
        totalPages.value = totalPagesFromApi; 
      }

      
      filterCustomers();
    } catch (e) {
      print('Error en el controlador al cargar clientes: $e');
      noClientMessage.value = "Error al cargar los clientes. Intente nuevamente.";
      
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
      
      
      if (searchQuery.value.isNotEmpty) {
        filterCustomers();
      }
      
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
    
    final query = searchQuery.value.trim().toLowerCase();
    
    
    final List<CustomerModel> sourceList;
    if (query.isEmpty) {
      sourceList = customers;
    } else {
      
      sourceList = allCustomers.isNotEmpty ? allCustomers : customers;
    }

    if (query.isEmpty) {
      filteredCustomers.assignAll(sourceList);
    } else {
      filteredCustomers.assignAll(
        sourceList.where((customer) {
          final name = customer.name.toLowerCase();
          final secondName = customer.secondName.toLowerCase();
          final email = customer.email.toLowerCase();
          final phone = customer.contactNumber;
          
          return name.contains(query) ||
                 secondName.contains(query) ||
                 email.contains(query) ||
                 phone.contains(query);
        }).toList(),
      );
    }

    filteredCustomers.refresh();
  }

  
  Future<bool> updateCustomer({
    required String customerId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      isLoading.value = true;
      print('🎮 Controller: Iniciando actualización de cliente ID: $customerId');
      
      final updatedCustomer = await repository.updateCustomer(
        customerId: customerId,
        updateData: updateData,
      );
      
      print('🎮 Controller: Cliente actualizado desde backend: ${updatedCustomer.name}');
      
      final index = customers.indexWhere((c) => c.id == customerId);
      print('🎮 Controller: Índice del cliente en la lista: $index');
      
      if (index != -1) {
        print('🎮 Controller: Cliente antes de actualizar: ${customers[index].name}');
        customers[index] = updatedCustomer;
        print('🎮 Controller: Cliente después de actualizar: ${customers[index].name}');
        
        customers.refresh();
        
        filterCustomers();
        print('🎮 Controller: Filtros aplicados, clientes filtrados: ${filteredCustomers.length}');
      } else {
        print('❌ Controller: Cliente no encontrado en la lista local');
      }
      
      return true;
    } catch (e) {
      print('❌ Controller: Error al actualizar cliente: $e');
      final errorMsg = 'Error al actualizar cliente: ${e.toString()}';
      noClientMessage.value = errorMsg;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  
  Future<bool> deleteCustomer(String customerId) async {
    try {
      isLoading.value = true;
      print('🎮 Controller: Iniciando eliminación de cliente ID: $customerId');
      
      await repository.deleteCustomer(customerId);
      print('🎮 Controller: Repository completó eliminación exitosamente');
      
      
      final removedCount = customers.length;
      customers.removeWhere((c) => c.id == customerId);
      print('🎮 Controller: Removidos ${removedCount - customers.length} clientes de la lista local');
      
      filterCustomers(); 
      print('🎮 Controller: Filtros actualizados');
      
      print('🎮 Controller: Retornando TRUE - eliminación exitosa');
      return true;
    } catch (e) {
      print('🎮 Controller: ERROR en eliminación: $e');
      final errorMsg = 'Error al eliminar cliente: ${e.toString()}';
      noClientMessage.value = errorMsg;
      print('🎮 Controller: Retornando FALSE - eliminación falló');
      return false;
    } finally {
      isLoading.value = false;
      print('🎮 Controller: isLoading = false');
    }
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

      
      Get.defaultDialog(
        title: "Éxito",
        middleText: "El cliente ha sido creado exitosamente.",
        textConfirm: "Aceptar",
        onConfirm: () async {
          Get.back(); 
          Get.back(); 
          
          
          currentPage.value = 1;
          await fetchCustomers();
        },
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFFFF8329),
      );
    } catch (e) {
      
      if (e.toString().contains("El email ya está registrado")) {
        Get.defaultDialog(
          title: "Error",
          middleText: "El email proporcionado ya está registrado.",
          textConfirm: "Aceptar",
          onConfirm: () => Get.back(), 
          confirmTextColor: Colors.white,
          buttonColor: Colors.red,
        );
      } else {
        
        Get.defaultDialog(
          title: "Error",
          middleText: "Hubo un problema al crear el cliente. Intente nuevamente.",
          textConfirm: "Aceptar",
          onConfirm: () => Get.back(), 
          confirmTextColor: Colors.white,
          buttonColor: Colors.red,
        );
      }
    } finally {
      isCreating.value = false;
    }
  }

  
  void updateSearchQuery(String query) {
    searchQuery.value = query.trim();

    
    if (searchQuery.value.isNotEmpty && allCustomers.isEmpty && !isLoadingAll.value) {
      fetchAllCustomers();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchCustomers();
    }
  }
}
