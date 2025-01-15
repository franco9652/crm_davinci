import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/features/budgets/controllers/budget_controller.dart';
import 'package:crm_app_dv/models/budget_model.dart';

class CreateBudgetScreen extends StatelessWidget {
  final BudgetController budgetController = Get.find<BudgetController>();

  final projectAddressController = TextEditingController();
  final projectTypeController = TextEditingController();
  final m2Controller = TextEditingController();
  final levelsController = TextEditingController();
  final roomsController = TextEditingController();
  final materialsController = TextEditingController();
  final approvalsController = TextEditingController();
  final subcontractorsController = TextEditingController();
  final estimatedBudgetController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      controller.text = pickedDate.toIso8601String().split('T')[0];
    }
  }

  void _createBudget() {
    final budget = BudgetModel(
      workId: budgetController.selectedWorkId.value,
      customerId: budgetController.selectedCustomerId.value,
      customerName: "Juan Pérez",
      email: "juanperez@example.com",
      projectAddress: projectAddressController.text,
      projectType: projectTypeController.text,
      m2: m2Controller.text,
      levels: levelsController.text,
      rooms: roomsController.text,
      materials: materialsController.text.split(','),
      demolition: false,
      approvals: approvalsController.text.split(','),
      budgetDate: DateTime.now().toIso8601String().split('T')[0],
      subcontractors: subcontractorsController.text.split(','),
      startDate: startDateController.text,
      endDate: endDateController.text,
      estimatedBudget: double.parse(estimatedBudgetController.text),
      currency: "USD",
      advancePayment: true,
      documentation: [],
      status: "ACEPTADO",
    );
    budgetController.createBudget(budget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Presupuesto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (budgetController.isLoadingCustomers.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              DropdownButtonFormField<String>(
                value: budgetController.selectedCustomerId.value.isEmpty
                    ? null
                    : budgetController.selectedCustomerId.value,
                items: budgetController.customers.map((customer) {
                  return DropdownMenuItem<String>(
                    value: customer.userId,
                    child: Text(
                      customer.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) async {
                  if (value != null) {
                    budgetController.selectedCustomerId.value = value;
                    await budgetController.fetchWorksForCustomer(value);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Seleccionar Cliente',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Color(0xFF242038),
                ),
                dropdownColor: const Color(0xFF1B1926),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 15),
              Obx(() {
                if (budgetController.isLoadingWorks.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return DropdownButtonFormField<String>(
                  value: budgetController.selectedWorkId.value.isEmpty
                      ? null
                      : budgetController.selectedWorkId.value,
                  items: budgetController.worksForCustomer.map((work) {
                    return DropdownMenuItem<String>(
                      value: work.id,
                      child: Text(
                        work.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      budgetController.selectedWorkId.value = value;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar Trabajo',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Color(0xFF242038),
                  ),
                  dropdownColor: const Color(0xFF1B1926),
                  style: const TextStyle(color: Colors.white),
                );
              }),
              const SizedBox(height: 15),
              TextFormField(
                controller: projectAddressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección del Proyecto',
                ),
              ),
              TextFormField(
                controller: projectTypeController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Proyecto',
                ),
              ),
              TextFormField(
                controller: m2Controller,
                decoration: const InputDecoration(
                  labelText: 'Tamaño en m²',
                ),
              ),
              // Más inputs...
              ElevatedButton(
                onPressed: _createBudget,
                child: const Text('Crear Presupuesto'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
