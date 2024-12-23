import 'package:crm_app_dv/core/domain/repositories/customer_repository.dart';
import 'package:crm_app_dv/core/domain/repositories/works_repository.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/models/work_model.dart';

class WorkController extends GetxController {
  final WorkRepository repository;
  final CustomerRepository customerRepository;

  WorkController({required this.repository, required this.customerRepository});

  final works = <WorkModel>[].obs;
  final customers = <CustomerModel>[].obs;
  final isLoading = false.obs;
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
          await repository.getAllWorks(currentPage.value, limit);
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
    // Este método obtiene clientes del repositorio de clientes
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

  void goToPage(int page) {
    if (page < 1 || page > totalPages.value) return;
    currentPage.value = page;
    fetchWorks();
  }


    Future<void> createWork(WorkModel work) async {
    try {
      await repository.createWork(work);
      Get.defaultDialog(
        title: "Éxito",
        middleText: "El proyecto ha sido creado correctamente.",
      );
      fetchWorks(); // Refresca la lista de trabajos después de crear uno nuevo
    } catch (e) {
      Get.defaultDialog(
        title: "Error",
        middleText: "No se pudo crear el proyecto: $e",
      );
    }
  }
}
