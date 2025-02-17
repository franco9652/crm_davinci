import 'dart:convert';
import 'package:get/get.dart';
import 'package:crm_app_dv/core/domain/repositories/works_repository.dart';
import 'package:crm_app_dv/models/work_model.dart';

class WorkInfoController extends GetxController {
  final WorkRepository workRepository;
  WorkInfoController({required this.workRepository});

  var work = Rxn<WorkModel>(); // Modelo del trabajo
  var isLoadingWork = false.obs; // Estado de carga

  Future<void> fetchWorkInfo(String workId) async {
    if (workId.isEmpty) {
      Get.snackbar("Error", "El ID del trabajo no es válido");
      return;
    }
    try {
      isLoadingWork(true);
      update();

      print("🟢 Work ID recibido en WorkInfoController: $workId");

      final response = await workRepository.getWorkById(workId);
      print("🔵 JSON recibido para deserializar: $response");
      print("🔵 Tipo de response: ${response.runtimeType}");

      if (response is WorkModel) {
        print("✅ WorkModel asignado correctamente: ${response.name}");
        work.value = response;
        print("🟢 WorkModel después de asignación: ${work.value?.name}");
        update();
      } else {
        print("❌ Respuesta inesperada: $response");
      }
    } catch (e) {
      print("🔴 Error en fetchWorkInfo: $e");
    } finally {
      isLoadingWork(false);
      update();
    }
  }

  // ✅ **Método para convertir y asignar el modelo**
  void _assignWorkModel(Map<String, dynamic> json) {
    if (json.containsKey("work")) {
      print("✅ JSON contiene 'work', extrayendo y convirtiendo...");
      work.value = WorkModel.fromJson(json["work"]);
    } else {
      print(
          "⚠️ JSON sin clave 'work', intentando convertir toda la respuesta...");
      work.value = WorkModel.fromJson(json);
    }

    print("🟢 Trabajo actualizado en GetX: ${work.value?.name}");

    // 🔥 **Forzar actualización con delay para asegurar renderizado**
    Future.delayed(Duration(milliseconds: 100), () {
      update();
    });
  }
}
