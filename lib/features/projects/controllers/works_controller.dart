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

  // Lista de estados posibles
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
    filterWorks(); // Aplicar filtro inmediatamente
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
      await fetchWorks(); // Refrescar lista de obras después de crear una nueva

      // Mostrar mensaje de éxito y volver al listado
      Get.defaultDialog(
        title: "Éxito",
        middleText: "El proyecto ha sido creado correctamente.",
        textConfirm: "Aceptar",
        onConfirm: () {
          Get.back(); // Cierra el pop-up
          Get.offNamed(AppRoutes.projects); // Navega directamente al listado
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

  /// Actualizar obra usando PATCH (actualización parcial) - Senior approach
  Future<bool> updateWork({
    required String workId, // Usar _id de MongoDB
    required Map<String, dynamic> updateData,
  }) async {
    try {
      isLoading.value = true;
      
      final updatedWork = await workRepository.updateWork(
        workId: workId,
        updateData: updateData,
      );
      
      // Actualizar la lista local (optimistic update)
      final index = works.indexWhere((w) => w.id == workId);
      if (index != -1) {
        works[index] = updatedWork;
        filterWorks(); // Refrescar filtros
      }
      
      // También actualizar en worksByCustomer si existe
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

  /// Actualizar obra completa usando PUT - Senior approach
  Future<bool> updateWorkComplete({
    required String workId, // Usar _id de MongoDB
    required WorkModel work,
  }) async {
    try {
      isLoading.value = true;
      
      final workData = workRepository.workModelToUpdateMap(work);
      final updatedWork = await workRepository.updateWorkComplete(
        workId: workId,
        workData: workData,
      );
      
      // Actualizar la lista local (optimistic update)
      final index = works.indexWhere((w) => w.id == workId);
      if (index != -1) {
        works[index] = updatedWork;
        filterWorks(); // Refrescar filtros
      }
      
      // También actualizar en worksByCustomer si existe
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

  /// Eliminar obra - Senior approach
  Future<bool> deleteWork({
    required String workAutoIncrementId, // Usar ID auto-increment
    required String workMongoId, // Para remover de listas locales
  }) async {
    try {
      isLoading.value = true;
      print('🎮 Controller: Iniciando eliminación de obra');
      print('   - ID auto-increment: $workAutoIncrementId');
      print('   - ID MongoDB: $workMongoId');
      
      // Agregar timeout para evitar carga infinita
      await workRepository.deleteWork(workAutoIncrementId).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: La operación tardó demasiado tiempo');
        },
      );
      
      print('🎮 Controller: Eliminación exitosa, actualizando listas locales');
      
      // Remover de las listas locales (optimistic update)
      works.removeWhere((w) => w.id == workMongoId);
      worksByCustomer.removeWhere((w) => w.id == workMongoId);
      filterWorks(); // Refrescar filtros
      
      Get.snackbar(
        'Éxito',
        'Obra eliminada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
      
      return true;
    } catch (e) {
      print('🎮 Controller: Error al eliminar obra: $e');
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

  /// Helper para obtener el ID auto-increment de una obra (Senior approach)
  /// Nota: Este método maneja la inconsistencia entre MongoDB _id y auto-increment ID
  String? getWorkAutoIncrementId(WorkModel work) {
    // Primero intentar usar el campo number si existe y no está vacío
    if (work.number != null && work.number!.isNotEmpty && work.number != 'T000') {
      print('🆔 Usando number como ID auto-increment: ${work.number}');
      return work.number;
    }
    
    // Si no hay number válido, usar el _id de MongoDB como fallback
    // Nota: Esto puede no funcionar si el backend espera específicamente un ID numérico
    if (work.id != null && work.id!.isNotEmpty) {
      print('⚠️ Usando MongoDB _id como fallback: ${work.id}');
      return work.id;
    }
    
    print('❌ No se encontró ID válido para la obra: ${work.name}');
    return null;
  }

  /// Refrescar lista de obras después de cambios
  Future<void> refreshWorks() async {
    currentPage.value = 1;
    await fetchWorks();
  }
}
