import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:crm_app_dv/models/work_model.dart';
import 'package:crm_app_dv/features/customer/controllers/customer_controller.dart';
import 'package:crm_app_dv/features/projects/controllers/works_controller.dart';
import 'package:crm_app_dv/features/budgets/controllers/budget_controller.dart';
import 'package:crm_app_dv/models/budget_model.dart';

class CreateBudgetScreen extends StatefulWidget {
  @override
  _CreateBudgetScreenState createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  final HomeController customerController = Get.find<HomeController>();
  final WorkController workController = Get.find<WorkController>();
  final BudgetController budgetController = Get.find<BudgetController>();

  CustomerModel? selectedCustomer;
  WorkModel? selectedWork;
  final projectAddressController = TextEditingController();
  final projectTypeController = TextEditingController();
  final m2Controller = TextEditingController();
  final estimatedBudgetController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      customerController.fetchCustomers();
    });
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = pickedDate.toIso8601String().split('T')[0];
      });
    }
  }

  void _createBudget() {
    if (selectedCustomer == null || selectedWork == null) {
      Get.snackbar('Error', 'Debe seleccionar un cliente y un trabajo');
      return;
    }

    final budget = BudgetModel(
      workId: selectedWork!.id!,
      customerId: selectedCustomer!.id!,
      customerName: selectedCustomer!.name,
      email: selectedCustomer!.email ?? '',
      projectAddress: projectAddressController.text,
      projectType: projectTypeController.text,
      m2: m2Controller.text,
      budgetDate: DateTime.now().toIso8601String().split('T')[0],
      startDate: startDateController.text,
      endDate: endDateController.text,
      estimatedBudget: double.parse(estimatedBudgetController.text),
      currency: 'USD',
      status: 'PENDIENTE',
    );

    budgetController.createBudget(budget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B1926),
      appBar: AppBar(
        title: Text('Crear Presupuesto'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (customerController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completa los datos para crear un presupuesto',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),

                // Dropdown para seleccionar cliente
                DropdownButtonFormField<CustomerModel>(
                  value: selectedCustomer,
                  items: customerController.customers.map((customer) {
                    return DropdownMenuItem(
                      value: customer,
                      child: Text(
                        customer.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (CustomerModel? value) async {
                    setState(() {
                      selectedCustomer = value;
                      selectedWork = null; // Reinicia el Work seleccionado
                    });
                    if (value != null) {
                      await workController.fetchWorksByCustomer(value.id!);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Seleccionar Cliente',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF242038),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  dropdownColor: const Color(0xFF1B1926),
                  style: const TextStyle(color: Colors.white),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  hint: const Text('Seleccione un cliente'),
                ),
                SizedBox(height: 15),

                // Dropdown para seleccionar trabajo asociado al cliente
                Obx(() {
                  if (workController.isLoadingWorks.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return DropdownButtonFormField<WorkModel>(
                    value: selectedWork,
                    items: workController.worksByCustomer.map((work) {
                      return DropdownMenuItem(
                        value: work,
                        child: Text(
                          work.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: selectedCustomer == null
                        ? null // Deshabilitar si no hay cliente seleccionado
                        : (WorkModel? value) {
                            setState(() {
                              selectedWork = value;
                            });
                          },
                    decoration: InputDecoration(
                      labelText: 'Seleccionar Trabajo',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: selectedCustomer == null
                          ? Colors.grey.shade800
                          : const Color(0xFF242038),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    dropdownColor: const Color(0xFF1B1926),
                    style: const TextStyle(color: Colors.white),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    hint: const Text('Seleccione un trabajo'),
                  );
                }),
                SizedBox(height: 15),

                _buildTextField(projectAddressController, 'Dirección del Proyecto'),
                SizedBox(height: 15),
                _buildTextField(projectTypeController, 'Tipo de Proyecto'),
                SizedBox(height: 15),
                _buildTextField(m2Controller, 'Tamaño en m²'),
                SizedBox(height: 15),
                _buildTextField(estimatedBudgetController, 'Presupuesto Estimado'),
                SizedBox(height: 15),

                GestureDetector(
                  onTap: () => _selectDate(context, startDateController),
                  child: AbsorbPointer(
                    child: _buildTextField(startDateController, 'Fecha de Inicio'),
                  ),
                ),
                SizedBox(height: 15),
                GestureDetector(
                  onTap: () => _selectDate(context, endDateController),
                  child: AbsorbPointer(
                    child: _buildTextField(endDateController, 'Fecha de Fin'),
                  ),
                ),
                SizedBox(height: 30),

                Center(
                  child: ElevatedButton(
                    onPressed: _createBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6C5DD3),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Crear Presupuesto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Color(0xFF2C2A37),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
