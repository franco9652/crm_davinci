import 'package:crm_app_dv/core/domain/repositories/customer_repository.dart';
import 'package:crm_app_dv/features/customer/controllers/customer_info_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerInfoScreen extends StatelessWidget {
  final String userId;

  const CustomerInfoScreen({required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CustomerInfoController controller = Get.put(
      CustomerInfoController(customerRepository: Get.find<CustomerRepository>()),
    );

    controller.fetchCustomerInfo(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Información del Cliente"),
        backgroundColor: const Color(0xFF1B1926),
      ),
      body: Obx(() {
        if (controller.isLoadingCustomer.value ||
            controller.isLoadingWorks.value ||
            controller.isLoadingBudgets.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final customer = controller.customer.value;

        if (customer == null) {
          return const Center(
            child: Text("No se encontró información para este cliente"),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Información del Cliente"),
              Text("Nombre: ${customer.name}", style: const TextStyle(fontSize: 16)),
              Text("Email: ${customer.email}", style: const TextStyle(fontSize: 16)),
              Text("Dirección: ${customer.address}", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              _buildSectionTitle("Trabajos Activos"),
              controller.works.isEmpty
                  ? const Text("No hay trabajos activos")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.works.length,
                      itemBuilder: (context, index) {
                        final work = controller.works[index];
                        return Card(
                          child: ListTile(
                            title: Text(work.name),
                            subtitle: Text(work.description ?? "Sin descripción"),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 20),
              _buildSectionTitle("Presupuestos"),
              controller.budgets.isEmpty
                  ? const Text("No hay presupuestos registrados")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.budgets.length,
                      itemBuilder: (context, index) {
                        final budget = controller.budgets[index];
                        return Card(
                          child: ListTile(
                            title: Text("Presupuesto: \$${budget.estimatedBudget} ${budget.currency}"),
                            subtitle: Text("Estado: ${budget.status}"),
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
