import 'package:crm_app_dv/app_routes.dart';
import 'package:crm_app_dv/core/domain/repositories/customer_repository.dart';
import 'package:crm_app_dv/core/domain/repositories/works_repository.dart';
import 'package:crm_app_dv/features/projects/data/works_remote_data_source.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/models/work_model.dart';

class WorkController extends GetxController {
  final CustomerRepository customerRepository;
  final WorkRemoteDataSource workRemoteDataSource;
  final WorkRepository workRepository;

  WorkController({
    required this.customerRepository,
    required this.workRemoteDataSource,
    required this.workRepository,
  });

  final works = <WorkModel>[].obs;
  final customers = <CustomerModel>[].obs;
  final worksByCustomer = <WorkModel>[].obs;
  final isLoading = false.obs;
  final isLoadingWorks = false.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final noWorkMessage = "No hay proyectos disponibles.".obs;
  final searchQuery = ''.obs;
  final selectedStatus = ''.obs;
  final filteredWorks = <WorkModel>[].obs;
  final hasNextPage = true.obs;
  final limit = 10;

 
  final List<String> workStatuses = [
    'Activo',
    'Pausado',
    'Inactivo',
    'En Progreso',
  ];

  @override
  void onInit() {
    super.onInit();
    ever(searchQuery, (_) => filterWorks());
    ever(selectedStatus, (_) => filterWorks());
    fetchWorks();
  }

  Future<void> fetchWorks() async {
    if (isLoading.value) return;

    isLoading(true);
    try {
      final response = await workRemoteDataSource.getAllWorks(currentPage.value, limit);
      
      if (response.isEmpty) {
        noWorkMessage.value = "No hay proyectos disponibles.";
        works.clear();
        hasNextPage.value = false;
      } else {
        works.assignAll(response);
        hasNextPage.value = response.length >= limit;
      }

    } catch (e) {
      Get.snackbar("Error", "No se pudo cargar los proyectos: $e");
    } finally {
      isLoading(false);
      filterWorks();
    }
  }

  void filterWorks() {
    print('🔍 Filtrando obras:');
    print('   - Total obras: ${works.length}');
    print('   - Búsqueda: "${searchQuery.value}"');
    print('   - Estado seleccionado: "${selectedStatus.value}"');
    
    if (searchQuery.value.isEmpty && selectedStatus.value.isEmpty) {
      filteredWorks.assignAll(works);
      print('   - Sin filtros, mostrando todas: ${filteredWorks.length}');
    } else {
      final filtered = works.where((work) {
        final matchesSearch = searchQuery.value.isEmpty ||
            work.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            work.customerName.toLowerCase().contains(searchQuery.value.toLowerCase());
        
        final matchesStatus = selectedStatus.value.isEmpty ||
            work.statusWork.toLowerCase() == selectedStatus.value.toLowerCase();
        
        print('   - Obra: ${work.name}');
        print('     Estado obra: "${work.statusWork}"');
        print('     Coincide búsqueda: $matchesSearch');
        print('     Coincide estado: $matchesStatus');
        print('     Incluir: ${matchesSearch && matchesStatus}');
        
        return matchesSearch && matchesStatus;
      }).toList();
      
      filteredWorks.assignAll(filtered);
      print('   - Obras filtradas: ${filteredWorks.length}');
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateSelectedStatus(String? status) {
    print('📋 Actualizando estado seleccionado: "$status"');
    selectedStatus.value = status ?? '';
    print('📋 Estado guardado: "${selectedStatus.value}"');
    filterWorks(); 
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchWorks();
    }
  }

  Future<void> fetchCustomers() async {
    isLoading.value = true;
    try {
      final response = await customerRepository.fetchCustomers(1);
      customers.value = response['customers'];
    } catch (e) {
      Get.snackbar("Error", "No se pudo cargar la lista de clientes: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWorksByCustomer(String customerId) async {
    isLoadingWorks.value = true;
    try {
      final fetchedWorks = await workRemoteDataSource.getWorksByUserId(customerId);
      worksByCustomer.value = fetchedWorks;
    } catch (e) {
      Get.snackbar("Error", "No se pudieron cargar los trabajos del cliente: $e");
    } finally {
      isLoadingWorks.value = false;
    }
  }

  Future<void> createWork(WorkModel work) async {
    try {
      isLoading(true);
      await workRemoteDataSource.createWork(work);
      print("✅ Trabajo creado correctamente");
      await fetchWorks(); 

      
      Get.defaultDialog(
        title: "Éxito",
        middleText: "El proyecto ha sido creado correctamente.",
        textConfirm: "Aceptar",
        onConfirm: () {
          Get.back(); 
          Get.offNamed(AppRoutes.projects); 
        },
      );
    } catch (e) {
      Get.defaultDialog(
        title: "Error",
        middleText: "Error en la creación del proyecto:\n$e",
        textConfirm: "Aceptar",
        onConfirm: () => Get.back(),
      );
    } finally {
      isLoading(false);
    }
  }


  Future<bool> updateWork({
    required String workId, 
    required Map<String, dynamic> updateData,
  }) async {
    try {
      isLoading.value = true;
      
      final updatedWork = await workRepository.updateWork(
        workId: workId,
        updateData: updateData,
      );
      
     
      final index = works.indexWhere((w) => w.id == workId);
      if (index != -1) {
        works[index] = updatedWork;
        filterWorks(); 
      }
      
      
      final customerIndex = worksByCustomer.indexWhere((w) => w.id == workId);
      if (customerIndex != -1) {
        worksByCustomer[customerIndex] = updatedWork;
      }
      
      Get.snackbar(
        'Éxito',
        'Obra actualizada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al actualizar obra: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  
  Future<bool> updateWorkComplete({
    required String workId, 
    required WorkModel work,
  }) async {
    try {
      isLoading.value = true;
      
      final workData = workRepository.workModelToUpdateMap(work);
      final updatedWork = await workRepository.updateWorkComplete(
        workId: workId,
        workData: workData,
      );
      
      
      final index = works.indexWhere((w) => w.id == workId);
      if (index != -1) {
        works[index] = updatedWork;
        filterWorks();
      }
      
      
      final customerIndex = worksByCustomer.indexWhere((w) => w.id == workId);
      if (customerIndex != -1) {
        worksByCustomer[customerIndex] = updatedWork;
      }
      
      Get.snackbar(
        'Éxito',
        'Obra actualizada completamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al actualizar obra: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }


  Future<bool> deleteWork({
    required String workAutoIncrementId,
    required String workMongoId, 
  }) async {
    try {
      isLoading.value = true;
      print('Controller: Iniciando eliminación de obra');
      print('   - ID auto-increment: $workAutoIncrementId');
      print('   - ID MongoDB: $workMongoId');
      
      
      await workRepository.deleteWork(workMongoId).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: La operación tardó demasiado tiempo');
        },
      );
      
      print('Controller: Eliminación exitosa, actualizando listas locales');
      
     
      works.removeWhere((w) => w.id == workMongoId);
      worksByCustomer.removeWhere((w) => w.id == workMongoId);
      filterWorks(); 
      
     
      
      return true;
    } catch (e) {
      print('Controller: Error al eliminar obra: $e');
      Get.snackbar(
        'Error',
        'Error al eliminar obra: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  
  String? getWorkAutoIncrementId(WorkModel work) {
   
    if (work.number != null && work.number!.isNotEmpty && work.number != 'T000') {
      print('🆔 Usando number como ID auto-increment: ${work.number}');
      return work.number;
    }
    
    
    if (work.id != null && work.id!.isNotEmpty) {
      print('⚠️ Usando MongoDB _id como fallback: ${work.id}');
      return work.id;
    }
    
    print('❌ No se encontró ID válido para la obra: ${work.name}');
    return null;
  }

 
  Future<void> refreshWorks() async {
    currentPage.value = 1;
    await fetchWorks();
  }
}
