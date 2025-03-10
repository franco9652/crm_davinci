import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/features/budgets/controllers/budget_controller.dart';
import 'package:crm_app_dv/models/budget_model.dart';

class CreateBudgetScreen extends StatelessWidget {
  final BudgetController budgetController = Get.find<BudgetController>();

  final projectAddressController = TextEditingController();
  final projectTypeController = TextEditingController();
  final m2Controller = TextEditingController();
  final estimatedBudgetController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final materialsController = TextEditingController();
  final approvalsController = TextEditingController();
  final subcontractorsController = TextEditingController();

  void _createBudget() {
    if (budgetController.selectedCustomerId.value == null) {
      Get.snackbar("Error", "Selecciona un cliente primero.");
      return;
    }

    final parsedBudget = double.tryParse(estimatedBudgetController.text);
    if (parsedBudget == null) {
      Get.snackbar("Error", "Ingrese un número válido para el presupuesto.");
      return;
    }

    var selectedCustomer = budgetController.customers.firstWhere(
      (customer) =>
          customer['_id'] == budgetController.selectedCustomerId.value,
      orElse: () => {},
    );

    final budget = BudgetModel(
      customerId: budgetController.selectedCustomerId.value!,
      customerName: selectedCustomer['name'] ?? '',
      email: selectedCustomer['email'] ?? '',
      projectAddress: projectAddressController.text,
      projectType: projectTypeController.text,
      m2: m2Controller.text,
      materials: materialsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      approvals: approvalsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      subcontractors: subcontractorsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      budgetDate: DateTime.now().toIso8601String().split('T')[0],
      startDate: startDateController.text,
      endDate: endDateController.text,
      estimatedBudget: parsedBudget,
      currency: "USD",
      status: "DENEGADO",
      advancePayment: true,
      documentation: [],
    );

    budgetController.createBudget(budget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Presupuesto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: budgetController.selectedCustomerId.value,
              items: budgetController.customers
                  .map<DropdownMenuItem<String>>((customer) {
                return DropdownMenuItem<String>(
                  value: customer['userId'].toString(),
                  child: Text(customer['name'].toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  budgetController.selectedCustomerId.value = value;
                }
              },
              decoration:
                  const InputDecoration(labelText: 'Seleccionar Cliente'),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: projectAddressController,
              decoration:
                  const InputDecoration(labelText: 'Dirección del Proyecto'),
            ),
            TextFormField(
              controller: estimatedBudgetController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Presupuesto Estimado'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _createBudget,
              child: const Text('Crear Presupuesto'),
            ),
          ],
        ),
      ),
    );
  }
}
