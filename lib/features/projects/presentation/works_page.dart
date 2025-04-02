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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2937),
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Buscador
                TextField(
                  onChanged: controller.updateSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Buscar proyecto...',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF1B1926),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                // Filtro de estado
                DropdownButtonFormField<String>(
                  value: controller.selectedStatus.value.isEmpty ? null : controller.selectedStatus.value,
                  items: [
                    DropdownMenuItem<String>(
                      value: '',
                      child: Text('Todos los estados', style: TextStyle(color: Colors.white)),
                    ),
                    ...controller.workStatuses.map((status) => DropdownMenuItem<String>(
                      value: status,
                      child: Text(status, style: TextStyle(color: Colors.white)),
                    )).toList(),
                  ],
                  onChanged: controller.updateSelectedStatus,
                  decoration: InputDecoration(
                    hintText: 'Filtrar por estado',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.filter_list, color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF1B1926),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  dropdownColor: Color(0xFF1B1926),
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final displayedWorks = controller.searchQuery.isEmpty && controller.selectedStatus.isEmpty
                  ? controller.works
                  : controller.filteredWorks;

              if (displayedWorks.isEmpty) {
                return Center(
                  child: Text(
                    controller.noWorkMessage.value,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListView.builder(
                itemCount: displayedWorks.length,
                itemBuilder: (context, index) {
                  final work = displayedWorks[index];
                  return _buildWorkCard(work);
                },
              );
            }),
          ),
          _buildPagination(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'createWork', 
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
    return Obx(() => Container(
      color: const Color(0xFF1B1926),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: controller.currentPage.value > 1
                ? () => controller.goToPage(controller.currentPage.value - 1)
                : null,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            disabledColor: Colors.grey,
          ),
          ...List.generate(controller.totalPages.value, (index) {
            final pageIndex = index + 1;
            final isSelected = pageIndex == controller.currentPage.value;
            return GestureDetector(
              onTap: () => controller.goToPage(pageIndex),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFF8329)
                      : const Color(0xFF242038),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF4380FF)),
                ),
                child: Text(
                  pageIndex.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
          IconButton(
            onPressed: controller.currentPage.value < controller.totalPages.value
                ? () => controller.goToPage(controller.currentPage.value + 1)
                : null,
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            disabledColor: Colors.grey,
          ),
        ],
      ),
    ));
  }
}
