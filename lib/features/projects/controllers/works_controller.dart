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

  @override
  void onInit() {
    super.onInit();
    fetchWorks();
  }

  Future<void> fetchWorks({int limit = 10}) async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final fetchedWorks =
          await workRemoteDataSource.getAllWorks(currentPage.value, limit);
      print("Proyectos obtenidos: $fetchedWorks");
      if (fetchedWorks.isEmpty) {
        noWorkMessage.value = "No hay proyectos disponibles en este momento.";
      } else {
        works.value = fetchedWorks;
      }
    } catch (e) {
      Get.snackbar("Error", "No se pudo cargar los proyectos: $e");
    } finally {
      isLoading.value = false;
    }
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
      final fetchedWorks = await workRemoteDataSource.getWorksByCustomerId(customerId);
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
      await workRemoteDataSource
          .createWork(work); // Crea el proyecto sin excepción

      // Muestra el mensaje de éxito
      Get.defaultDialog(
        title: "Éxito",
        middleText: "El proyecto ha sido creado correctamente.",
        textConfirm: "Aceptar",
        onConfirm: () {
          Get.back(); // Cierra el pop-up
          Get.offNamed(AppRoutes.projects); // Navega directamente al listado
        },
      );

      // Refresca la lista de trabajos
      await fetchWorks();
    } catch (e) {
      // Manejo de errores
      Get.defaultDialog(
        title: "Error",
        middleText: "Error en la creación del proyecto:\n$e",
        textConfirm: "Aceptar",
        onConfirm: () => Get.back(), // Cierra el popup
      );
    }
  }
}
