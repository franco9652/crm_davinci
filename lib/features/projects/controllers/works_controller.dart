import 'package:crm_app_dv/app_routes.dart';
import 'package:crm_app_dv/core/domain/repositories/customer_repository.dart';
import 'package:crm_app_dv/features/projects/data/works_remote_data_source.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/models/work_model.dart';

class WorkController extends GetxController {
  final CustomerRepository customerRepository;
  final WorkRemoteDataSource workRemoteDataSource;

  WorkController({
    required this.customerRepository,
    required this.workRemoteDataSource,
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

  // Lista de estados posibles
  final List<String> workStatuses = [
    'En Proceso',
    'Completado',
    'Pausado',
    'Cancelado',
  ];

  @override
  void onInit() {
    super.onInit();
    ever(searchQuery, (_) => filterWorks());
    ever(selectedStatus, (_) => filterWorks());
    fetchWorks();
  }

  Future<void> fetchWorks({int limit = 10}) async {
    if (isLoading.value) return;

    isLoading(true);

    try {
      final response = await workRemoteDataSource.getAllWorks(currentPage.value, limit);
      
      if (response.isEmpty && currentPage.value == 1) {
        noWorkMessage.value = "No hay proyectos disponibles en este momento.";
        works.clear();
        totalPages.value = 1;
        hasNextPage.value = false;
      } else {
        works.assignAll(response);
        hasNextPage.value = response.length >= limit;
        
        // Actualizar el total de páginas basado en la respuesta actual
        if (response.isEmpty) {
          totalPages.value = currentPage.value - 1;
        } else if (!hasNextPage.value) {
          totalPages.value = currentPage.value;
        } else {
          totalPages.value = currentPage.value + 1;
        }
      }

    } catch (e) {
      Get.snackbar("Error", "No se pudo cargar los proyectos: $e");
    } finally {
      isLoading(false);
      filterWorks();
    }
  }

  void filterWorks() {
    filteredWorks.value = works.where((work) {
      final matchesSearch = searchQuery.isEmpty ||
          work.name.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesStatus = selectedStatus.isEmpty ||
          work.statusWork.toLowerCase() == selectedStatus.value.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateSelectedStatus(String? status) {
    selectedStatus.value = status ?? '';
  }

  Future<void> fetchCustomers() async {
    isLoading.value = true;
    try {
      final response = await customerRepository.fetchCustomers(1); // Página 1
      customers.value = response['customers'];
    } catch (e) {
      Get.snackbar("Error", "No se pudo cargar la lista de clientes: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWorksByCustomer(String customerId) async {
    if (isLoadingWorks.value) return;

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

  void goToPage(int page) {
    if (page < 1 || page > totalPages.value) return;
    currentPage.value = page;
    fetchWorks();
  }

  Future<void> createWork(WorkModel work) async {
    try {
      isLoading(true);
      await workRemoteDataSource.createWork(work);
      print(" Trabajo creado correctamente");

      // 
      await fetchWorks();

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
}
