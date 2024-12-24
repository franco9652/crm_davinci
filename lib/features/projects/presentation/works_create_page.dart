import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:crm_app_dv/models/work_model.dart';
import 'package:crm_app_dv/features/projects/controllers/works_controller.dart';
import 'package:crm_app_dv/features/customer/controllers/customer_controller.dart';

class CreateWorkPage extends StatefulWidget {
  const CreateWorkPage({Key? key}) : super(key: key);

  @override
  State<CreateWorkPage> createState() => _CreateWorkPageState();
}

class _CreateWorkPageState extends State<CreateWorkPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final budgetController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final statusWorkController = TextEditingController();
  final workUbicationController = TextEditingController();
  final projectTypeController = TextEditingController();

  final WorkController workController = Get.find<WorkController>();
  final HomeController customerController = Get.find<HomeController>();

  CustomerModel? selectedCustomer;

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
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1926),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1926),
        title: const Text(
          'Crear Proyecto',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Obx(() {
        if (customerController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    onChanged: (CustomerModel? value) {
                      setState(() {
                        selectedCustomer = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Seleccionar Cliente',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF242038), // Fondo oscuro
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blueAccent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    dropdownColor:
                        const Color(0xFF1B1926), // Fondo del menú desplegable
                    style: const TextStyle(
                      color: Colors.white, // Color del texto
                      fontSize: 14, // Tamaño del texto
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white, // Color del icono
                    ),
                    hint: const Text(
                      'Seleccione un cliente',
                      style: TextStyle(color: Colors.white38),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(nameController, 'Nombre del Proyecto'),
                  const SizedBox(height: 16),
                  _buildTextField(addressController, 'Dirección'),
                  const SizedBox(height: 16),
                  _buildTextField(budgetController, 'Presupuesto',
                      inputType: TextInputType.number),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _selectDate(context, startDateController),
                    child: AbsorbPointer(
                      child: _buildTextField(
                          startDateController, 'Fecha de Inicio'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _selectDate(context, endDateController),
                    child: AbsorbPointer(
                      child: _buildTextField(
                          endDateController, 'Fecha de Fin (opcional)'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                      workUbicationController, 'Ubicación del Proyecto'),
                  const SizedBox(height: 16),
                  _buildTextField(statusWorkController,
                      'Estado del Proyecto (activo, pausado, inactivo)'),
                  const SizedBox(height: 16),
                  _buildTextField(projectTypeController,
                      'Tipo de Proyecto (residencial, comercial, industrial)'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          selectedCustomer != null) {
                        final work = WorkModel(
                          name: nameController.text,
                          userId: [
                            selectedCustomer!.id ?? ''
                          ], // Convertimos a lista
                          address: addressController.text,
                          startDate: startDateController.text,
                          endDate: endDateController.text.isNotEmpty
                              ? endDateController.text
                              : null,
                          budget: double.parse(budgetController.text),
                          statusWork: statusWorkController.text,
                          workUbication: workUbicationController.text,
                          projectType: projectTypeController.text,
                          documents: [], // Inicializamos como lista vacía
                          employeeInWork: [], // Inicializamos como lista vacía
                        );

                        await workController.createWork(work);
                        Get.back();
                      } else {
                        Get.snackbar(
                          'Error',
                          'Por favor complete todos los campos requeridos.',
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Crear Proyecto'),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: const Color(0xFF242038),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
