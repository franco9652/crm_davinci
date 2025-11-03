import 'dart:math';
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
  final emailCustomerController = TextEditingController();

  final WorkController workController = Get.find<WorkController>();
  final HomeController customerController = Get.find<HomeController>();

  CustomerModel? selectedCustomer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      customerController.fetchAllCustomers(); 
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
      backgroundColor: const Color(0xFF0F0F23),
      body: Obx(() {
        if (customerController.isLoadingAll.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
           
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
                                  Icons.add_business,
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
                                      'Crear Proyecto',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Completa la información del nuevo proyecto',
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
            
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     
                      _buildFormSection(
                        'Cliente',
                        Icons.person,
                        const Color(0xFF6366F1),
                        [
                          _buildModernDropdownField(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                    
                      _buildFormSection(
                        'Información Básica',
                        Icons.info,
                        const Color(0xFF8B5CF6),
                        [
                          _buildModernTextField(
                            nameController,
                            "Nombre del Proyecto",
                            Icons.business,
                            isRequired: true,
                          ),
                          _buildModernTextField(
                            addressController,
                            "Dirección",
                            Icons.location_on,
                            isRequired: true,
                          ),
                          _buildModernTextField(
                            workUbicationController,
                            "Ubicación del Proyecto",
                            Icons.place,
                            isRequired: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      
                      _buildFormSection(
                        'Presupuesto y Cronograma',
                        Icons.attach_money,
                        const Color(0xFF10B981),
                        [
                          _buildModernTextField(
                            budgetController,
                            "Presupuesto",
                            Icons.attach_money,
                            isNumeric: true,
                            isRequired: true,
                          ),
                          _buildModernDateField(
                            startDateController,
                            "Fecha de Inicio",
                            Icons.calendar_today,
                            context,
                            isRequired: true,
                          ),
                          _buildModernDateField(
                            endDateController,
                            "Fecha de Finalización (Opcional)",
                            Icons.event_available,
                            context,
                            isRequired: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                    
                      _buildFormSection(
                        'Detalles del Proyecto',
                        Icons.settings,
                        const Color(0xFFF59E0B),
                        [
                          _buildModernDropdownStatus(),
                          _buildModernDropdownProjectType(),
                          _buildModernTextField(
                            emailCustomerController,
                            "Email del Cliente",
                            Icons.email,
                            isRequired: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      
                   
                      _buildCreateButton(),
                      
                      const SizedBox(height: 100), 
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  
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

  
  Widget _buildModernTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumeric = false,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        validator: isRequired ? (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        } : null,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  
  Widget _buildModernDateField(
    TextEditingController controller,
    String label,
    IconData icon,
    BuildContext context, {
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: const TextStyle(color: Colors.white),
        validator: isRequired ? (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        } : null,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onTap: () => _selectDate(context, controller),
      ),
    );
  }

  
  Widget _buildModernDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<CustomerModel>(
        value: selectedCustomer,
        items: customerController.allCustomers.map((customer) {
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
            emailCustomerController.text = value?.email ?? '';
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Debe seleccionar un cliente';
          }
          return null;
        },
        dropdownColor: const Color(0xFF1E293B),
        style: const TextStyle(color: Colors.white),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
        decoration: InputDecoration(
          labelText: 'Seleccionar Cliente',
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
            child: const Icon(Icons.person_outline, color: Color(0xFF6366F1), size: 18),
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        hint: Text(
          'Seleccione un cliente',
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      ),
    );
  }

 
  Widget _buildModernDropdownStatus() {
    final statusOptions = ['Activo', 'Pausado', 'Inactivo'];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: statusWorkController.text.isEmpty ? null : statusWorkController.text,
        items: statusOptions.map((status) {
          Color statusColor;
          IconData statusIcon;
          
          switch (status.toLowerCase()) {
            case 'activo':
              statusColor = const Color(0xFF10B981);
              statusIcon = Icons.play_circle_filled;
              break;
            case 'pausado':
              statusColor = const Color(0xFFF59E0B);
              statusIcon = Icons.pause_circle_filled;
              break;
            case 'inactivo':
              statusColor = const Color(0xFFEF4444);
              statusIcon = Icons.stop_circle;
              break;
            default:
              statusColor = const Color(0xFF6B7280);
              statusIcon = Icons.help_outline;
          }
          
          return DropdownMenuItem(
            value: status,
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 16),
                const SizedBox(width: 8),
                Text(status, style: TextStyle(color: statusColor)),
              ],
            ),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            statusWorkController.text = value ?? '';
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Debe seleccionar un estado';
          }
          return null;
        },
        dropdownColor: const Color(0xFF1E293B),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
        decoration: InputDecoration(
          labelText: 'Estado del Proyecto',
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
            child: const Icon(Icons.timeline, color: Color(0xFF6366F1), size: 18),
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        hint: Text(
          'Seleccione el estado',
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      ),
    );
  }

  
  Widget _buildModernDropdownProjectType() {
    final projectTypes = ['Residencial', 'Comercial', 'Industrial'];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: projectTypeController.text.isEmpty ? null : projectTypeController.text,
        items: projectTypes.map((type) {
          Color typeColor;
          IconData typeIcon;
          
          switch (type.toLowerCase()) {
            case 'residencial':
              typeColor = const Color(0xFF8B5CF6);
              typeIcon = Icons.home;
              break;
            case 'comercial':
              typeColor = const Color(0xFF06B6D4);
              typeIcon = Icons.business;
              break;
            case 'industrial':
              typeColor = const Color(0xFFF59E0B);
              typeIcon = Icons.factory;
              break;
            default:
              typeColor = const Color(0xFF6B7280);
              typeIcon = Icons.category;
          }
          
          return DropdownMenuItem(
            value: type,
            child: Row(
              children: [
                Icon(typeIcon, color: typeColor, size: 16),
                const SizedBox(width: 8),
                Text(type, style: TextStyle(color: typeColor)),
              ],
            ),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            projectTypeController.text = value ?? '';
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Debe seleccionar un tipo de proyecto';
          }
          return null;
        },
        dropdownColor: const Color(0xFF1E293B),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
        decoration: InputDecoration(
          labelText: 'Tipo de Proyecto',
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
            child: const Icon(Icons.category, color: Color(0xFF6366F1), size: 18),
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        hint: Text(
          'Seleccione el tipo',
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      ),
    );
  }

 
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
      child: Obx(() => ElevatedButton.icon(
        onPressed: workController.isLoading.value ? null : () async {
          if (_formKey.currentState!.validate() && selectedCustomer != null) {
            try {
              final work = WorkModel(
                customerId: selectedCustomer!.id ?? '',
                name: nameController.text,
                userId: [selectedCustomer!.userId ?? ''],
                address: addressController.text,
                startDate: startDateController.text,
                endDate: endDateController.text.isNotEmpty ? endDateController.text : null,
                budget: double.parse(budgetController.text),
                customerName: selectedCustomer!.name,
                emailCustomer: emailCustomerController.text,
                number: generateRandomNumber(),
                statusWork: statusWorkController.text,
                workUbication: workUbicationController.text,
                projectType: projectTypeController.text,
                documents: [],
                employeeInWork: [],
              );

              await workController.createWork(work);
              
            } catch (e) {
              Get.snackbar(
                'Error',
                'Ocurrió un error inesperado: $e',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          } else {
            Get.snackbar(
              'Error',
              selectedCustomer == null
                  ? 'Seleccione un cliente'
                  : 'Por favor complete todos los campos requeridos.',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        icon: workController.isLoading.value 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
        label: Text(
          workController.isLoading.value ? 'Creando...' : 'Crear Proyecto',
          style: const TextStyle(
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
      )),
    );
  }

  
  String generateRandomNumber() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
}
