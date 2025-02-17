import 'package:crm_app_dv/features/projects/controllers/works_controller.dart';
import 'package:crm_app_dv/features/projects/presentation/work_info_screen.dart';
import 'package:crm_app_dv/features/projects/presentation/works_create_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/models/work_model.dart';

class WorkListPage extends StatelessWidget {
  final WorkController controller = Get.find<WorkController>();

  WorkListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1926),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1926),
        title: const Text(
          "Proyectos",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.works.isEmpty) {
          return Center(
            child: Text(
              controller.noWorkMessage.value,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller.works.length,
                itemBuilder: (context, index) {
                  final work = controller.works[index];
                  return _buildWorkCard(work);
                },
              ),
            ),
            _buildPagination(),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'createWork', // Añade un tag único
        onPressed: () {
          Get.to(() => const CreateWorkPage());
        },
        backgroundColor: const Color(0xFFFF8329),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildWorkCard(WorkModel work) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF242038),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFF4380FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            work.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Dirección: ${work.address}",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            "Presupuesto: \$${work.budget.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Estado: ${work.statusWork}",
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                "Tipo: ${work.projectType}",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  if (work.id != null && work.id!.isNotEmpty) {
                    Get.to(() => WorkInfoScreen(workId: work.id!));
                  } else {
                    Get.snackbar("Error", "El ID del trabajo no es válido");
                  }
                },
                icon: const Icon(Icons.info, color: Colors.white),
                label: const Text("Ver detalles"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Acción para enviar email
                },
                icon: const Icon(Icons.email, color: Colors.white),
                label: const Text("Email"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: controller.currentPage.value > 1
              ? () => controller.goToPage(controller.currentPage.value - 1)
              : null,
        ),
        Text(
          "${controller.currentPage.value} / ${controller.totalPages.value}",
          style: const TextStyle(color: Colors.white),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward, color: Colors.white),
          onPressed: controller.currentPage.value < controller.totalPages.value
              ? () => controller.goToPage(controller.currentPage.value + 1)
              : null,
        ),
      ],
    );
  }
}
