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

  // Listas de selección
  final List<String> materiales = [
    "Cemento",
    "Madera",
    "Vidrio",
    "Acero",
    "Ladrillos"
  ];
  final List<String> aprobaciones = [
    "Planos aprobados",
    "Permiso municipal",
    "Certificado ambiental"
  ];
  final List<String> subcontratistas = [
    "Electricidad",
    "Plomería",
    "Pintura",
    "Carpintero",
    "Albañil"
  ];

  /// 📌 **Abrir DatePicker**
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  /// 📌 **Crear Presupuesto**
  void _createBudget() async {
    if (budgetController.selectedCustomerId.value == null) {
      Get.snackbar("Error", "Selecciona un cliente primero.");
      return;
    }

    if (startDateController.text.isEmpty || endDateController.text.isEmpty) {
      Get.snackbar("Error", "Selecciona una fecha de inicio y finalización.");
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

    if (selectedCustomer.isEmpty) {
      Get.snackbar("Error", "El cliente seleccionado no existe.");
      return;
    }

    final budget = BudgetModel(
      customerId: budgetController.selectedCustomerId.value!,
      customerName: selectedCustomer['name'] ?? '',
      email: selectedCustomer['email'] ?? '',
      projectAddress: projectAddressController.text,
      projectType: projectTypeController.text,
      m2: m2Controller.text,
      materials: budgetController.selectedMaterials.toList(),
      approvals: budgetController.selectedApprovals.toList(),
      subcontractors: budgetController.selectedSubcontractors.toList(),
      budgetDate: DateTime.now().toIso8601String().split('T')[0],
      startDate: startDateController.text,
      endDate: endDateController.text,
      estimatedBudget: parsedBudget,
      currency: "USD",
      status: "DENEGADO",
      advancePayment: true,
      documentation: [],
    );
    try {
      bool success = await budgetController.createBudget(budget);
      if (success) {
        Get.defaultDialog(
          title: "Éxito",
          middleText: "Presupuesto creado correctamente.",
          textConfirm: "Aceptar",
          onConfirm: () {
            Get.back();
            Get.offNamed("/budgets");
          },
        );
      }
    } catch (e) {
      Get.defaultDialog(
        title: "Error",
        middleText: "No se pudo crear el presupuesto: $e",
        textConfirm: "Aceptar",
        onConfirm: () => Get.back(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Crear Presupuesto',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Color(0xFF1E293B),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: ListView(
          children: [
            Obx(() => _buildDropdownField(
                  "Seleccionar Cliente",
                  budgetController.selectedCustomerId.value,
                  budgetController.customers
                      .map<DropdownMenuItem<String>>((customer) {
                    return DropdownMenuItem<String>(
                      value: customer['_id'].toString(),
                      child: Text(customer['name'].toString(),
                          style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  (value) {
                    if (value != null)
                      budgetController.selectedCustomerId.value = value;
                  },
                )),
            _buildTextField(projectAddressController, "Dirección del Proyecto"),
            _buildTextField(projectTypeController, "Tipo de Proyecto"),
            _buildTextField(m2Controller, "Metros Cuadrados (m²)",
                isNumeric: true),
            _buildTextField(estimatedBudgetController, "Presupuesto Estimado",
                isNumeric: true),
            _buildDateField(startDateController, "Fecha de inicio", context),
            _buildDateField(
                endDateController, "Fecha de finalización", context),
            _buildMultiSelectDropdown(
                "Materiales", materiales, budgetController.selectedMaterials),
            _buildMultiSelectDropdown("Aprobaciones", aprobaciones,
                budgetController.selectedApprovals),
            _buildMultiSelectDropdown("Subcontratistas",
                subcontratistas, budgetController.selectedSubcontractors),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Crear Presupuesto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: Colors.white),
        decoration: _inputDecoration(label),
      ),
    );
  }

  Widget _buildDateField(
      TextEditingController controller, String label, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: TextStyle(color: Colors.white),
        decoration: _inputDecoration(label).copyWith(
          suffixIcon: Icon(Icons.calendar_today, color: Colors.white70),
        ),
        onTap: () => _selectDate(context, controller),
      ),
    );
  }

  Widget _buildMultiSelectDropdown(
      String label, List<String> options, RxList<String> selectedValues) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(
          canvasColor: const Color(0xFF1E293B), // Color de fondo del menú desplegable
        ),
        child: DropdownButtonFormField<String>(
          value: selectedValues.isEmpty ? null : selectedValues.last,
          items: options.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null && !selectedValues.contains(value)) {
              selectedValues.add(value);
            }
          },
          dropdownColor: const Color(0xFF1E293B), // Color de fondo del menú desplegable
          style: const TextStyle(color: Colors.white), // Color del texto seleccionado
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          decoration: _inputDecoration(label),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value,
      List<DropdownMenuItem<String>> items, Function(String?)? onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(
          canvasColor: const Color(0xFF1E293B), // Color de fondo del menú desplegable
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: const Color(0xFF1E293B), // Color de fondo del menú desplegable
          style: const TextStyle(color: Colors.white), // Color del texto seleccionado
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          decoration: _inputDecoration(label),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B82F6)),
      ),
    );
  }
}
