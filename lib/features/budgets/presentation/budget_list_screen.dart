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
      backgroundColor: const Color(0xFF0F0F23),
      body: CustomScrollView(
        slivers: [
          // App Bar moderno con gradiente
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1E293B),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                      Color(0xFF1E293B),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.receipt_long,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Crear Presupuesto',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Completa la información del proyecto',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Contenido principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección Cliente
                  _buildFormSection(
                    'Cliente',
                    Icons.person,
                    const Color(0xFF6366F1),
                    [
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => _buildModernDropdownField(
                              "Seleccionar Cliente",
                              budgetController.selectedCustomerId.value,
                              budgetController.customers
                                  .map<DropdownMenuItem<String>>((customer) {
                                return DropdownMenuItem<String>(
                                  value: customer['_id'].toString(),
                                  child: Text(
                                    customer['name'].toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                              (value) {
                                if (value != null)
                                  budgetController.selectedCustomerId.value = value;
                              },
                              Icons.person_outline,
                            )),
                          ),
                          const SizedBox(width: 12),
                          // 🔄 **Botón de refresh para clientes**
                          Obx(() => Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                              ),
                            ),
                            child: IconButton(
                              onPressed: budgetController.isLoading.value 
                                  ? null 
                                  : () => budgetController.fetchCustomers(),
                              icon: budgetController.isLoading.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF6366F1),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.refresh,
                                      color: Color(0xFF6366F1),
                                    ),
                              tooltip: 'Recargar clientes',
                            ),
                          )),
                        ],
                      ),
                      // 📊 **Contador de clientes**
                      Obx(() => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${budgetController.customers.length} clientes disponibles',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Sección Proyecto
                  _buildFormSection(
                    'Información del Proyecto',
                    Icons.business,
                    const Color(0xFF8B5CF6),
                    [
                      _buildModernTextField(
                        projectAddressController,
                        "Dirección del Proyecto",
                        Icons.location_on,
                      ),
                      _buildModernTextField(
                        projectTypeController,
                        "Tipo de Proyecto",
                        Icons.category,
                      ),
                      _buildModernTextField(
                        m2Controller,
                        "Metros Cuadrados (m²)",
                        Icons.square_foot,
                        isNumeric: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Sección Presupuesto y Fechas
                  _buildFormSection(
                    'Presupuesto y Cronograma',
                    Icons.attach_money,
                    const Color(0xFF10B981),
                    [
                      _buildModernTextField(
                        estimatedBudgetController,
                        "Presupuesto Estimado",
                        Icons.attach_money,
                        isNumeric: true,
                      ),
                      _buildModernDateField(
                        startDateController,
                        "Fecha de Inicio",
                        Icons.calendar_today,
                        context,
                      ),
                      _buildModernDateField(
                        endDateController,
                        "Fecha de Finalización",
                        Icons.event_available,
                        context,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Sección Recursos
                  _buildFormSection(
                    'Recursos del Proyecto',
                    Icons.build,
                    const Color(0xFFF59E0B),
                    [
                      _buildModernMultiSelect(
                        "Materiales",
                        materiales,
                        budgetController.selectedMaterials,
                        Icons.construction,
                        const Color(0xFFF59E0B),
                      ),
                      _buildModernMultiSelect(
                        "Aprobaciones",
                        aprobaciones,
                        budgetController.selectedApprovals,
                        Icons.verified,
                        const Color(0xFF06B6D4),
                      ),
                      _buildModernMultiSelect(
                        "Subcontratistas",
                        subcontratistas,
                        budgetController.selectedSubcontractors,
                        Icons.groups,
                        const Color(0xFF22C55E),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Botón de crear
                  _buildCreateButton(),
                  
                  const SizedBox(height: 100), // Espacio extra al final
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🏗️ **Sección de Formulario Moderna**
  Widget _buildFormSection(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  // 📝 **Campo de Texto Moderno**
  Widget _buildModernTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 18),
          ),
          filled: true,
          fillColor: const Color(0xFF0F172A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF334155).withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF334155).withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  // 📅 **Campo de Fecha Moderno**
  Widget _buildModernDateField(
    TextEditingController controller,
    String label,
    IconData icon,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 18),
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calendar_month, color: Color(0xFF10B981), size: 18),
          ),
          filled: true,
          fillColor: const Color(0xFF0F172A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF334155).withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF334155).withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onTap: () => _selectDate(context, controller),
      ),
    );
  }

  // 📋 **Dropdown Moderno**
  Widget _buildModernDropdownField(
    String label,
    String? value,
    List<DropdownMenuItem<String>> items,
    Function(String?)? onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        dropdownColor: const Color(0xFF1E293B),
        style: const TextStyle(color: Colors.white),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 18),
          ),
          filled: true,
          fillColor: const Color(0xFF0F172A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF334155).withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF334155).withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  // 🏷️ **Multi-Select Moderno**
  Widget _buildModernMultiSelect(
    String label,
    List<String> options,
    RxList<String> selectedValues,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                // Dropdown para agregar items
                DropdownButtonFormField<String>(
                  value: null,
                  hint: Text(
                    'Seleccionar $label',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                  ),
                  items: options.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null && !selectedValues.contains(value)) {
                      selectedValues.add(value);
                    }
                  },
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1E293B),
                  icon: Icon(Icons.add, color: color, size: 20),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: color.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: color.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: color, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                // Items seleccionados
                Obx(() => selectedValues.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF374151).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.white.withOpacity(0.5), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'No hay elementos seleccionados',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedValues.map((item) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: color.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => selectedValues.remove(item),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.close, color: color, size: 12),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🚀 **Botón de Crear Moderno**
  Widget _buildCreateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _createBudget,
        icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
        label: const Text(
          'Crear Presupuesto',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
