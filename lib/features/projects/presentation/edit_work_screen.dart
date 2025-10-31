import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/models/work_model.dart';
import 'package:crm_app_dv/features/projects/controllers/works_controller.dart';

class EditWorkScreen extends StatefulWidget {
  final WorkModel work;
  
  const EditWorkScreen({
    super.key,
    required this.work,
  });

  @override
  State<EditWorkScreen> createState() => _EditWorkScreenState();
}

class _EditWorkScreenState extends State<EditWorkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<WorkController>();
  
 
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _budgetController;
  late final TextEditingController _workUbicationController;
  late final TextEditingController _customerNameController;
  late final TextEditingController _emailCustomerController;
  late final TextEditingController _numberController;
  
  String _selectedStatus = 'activo';
  String _selectedProjectType = 'residencial';
  bool _isLoading = false;


  final List<String> _statusOptions = ['activo', 'pausado', 'inactivo', 'En progreso'];
  final List<String> _projectTypeOptions = ['residencial', 'comercial', 'industrial', 'Construcción'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.work.name);
    _addressController = TextEditingController(text: widget.work.address);
    _startDateController = TextEditingController(text: widget.work.startDate);
    _endDateController = TextEditingController(text: widget.work.endDate ?? '');
    _budgetController = TextEditingController(text: widget.work.budget.toString());
    _workUbicationController = TextEditingController(text: widget.work.workUbication);
    _customerNameController = TextEditingController(text: widget.work.customerName);
    _emailCustomerController = TextEditingController(text: widget.work.emailCustomer ?? '');
    _numberController = TextEditingController(text: widget.work.number ?? '');
    
    _selectedStatus = widget.work.statusWork;
    _selectedProjectType = widget.work.projectType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _budgetController.dispose();
    _workUbicationController.dispose();
    _customerNameController.dispose();
    _emailCustomerController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Editar Obra',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xFF1E293B),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          onPressed: _isLoading ? null : _saveChanges,
          icon: _isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save, color: Colors.white),
          tooltip: 'Guardar cambios',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildBasicInfoSection(),
            const SizedBox(height: 16),
            _buildDatesSection(),
            const SizedBox(height: 16),
            _buildBudgetSection(),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 16),
            _buildCustomerSection(),
            const SizedBox(height: 16),
            _buildStatusSection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.construction,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.work.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${widget.work.id ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_selectedStatus),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Información Básica',
      icon: Icons.info_outline,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Nombre del Proyecto *',
          icon: Icons.business_outlined,
          validator: (value) => value?.isEmpty == true ? 'Nombre requerido' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _numberController,
          label: 'Número de Obra',
          icon: Icons.numbers_outlined,
        ),
      ],
    );
  }

  Widget _buildDatesSection() {
    return _buildSection(
      title: 'Fechas del Proyecto',
      icon: Icons.calendar_today,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _startDateController,
                label: 'Fecha de Inicio *',
                icon: Icons.play_arrow_outlined,
                validator: (value) => value?.isEmpty == true ? 'Fecha de inicio requerida' : null,
                readOnly: true,
                onTap: () => _selectDate(context, _startDateController),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _endDateController,
                label: 'Fecha de Fin',
                icon: Icons.stop_outlined,
                readOnly: true,
                onTap: () => _selectDate(context, _endDateController),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetSection() {
    return _buildSection(
      title: 'Presupuesto',
      icon: Icons.attach_money,
      children: [
        _buildTextField(
          controller: _budgetController,
          label: 'Presupuesto *',
          icon: Icons.monetization_on_outlined,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty == true) return 'Presupuesto requerido';
            if (double.tryParse(value!) == null) return 'Ingrese un número válido';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildSection(
      title: 'Ubicación',
      icon: Icons.location_on,
      children: [
        _buildTextField(
          controller: _addressController,
          label: 'Dirección *',
          icon: Icons.home_outlined,
          maxLines: 2,
          validator: (value) => value?.isEmpty == true ? 'Dirección requerida' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _workUbicationController,
          label: 'Ubicación Específica',
          icon: Icons.place_outlined,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildCustomerSection() {
    return _buildSection(
      title: 'Información del Cliente',
      icon: Icons.person,
      children: [
        _buildTextField(
          controller: _customerNameController,
          label: 'Nombre del Cliente *',
          icon: Icons.person_outline,
          validator: (value) => value?.isEmpty == true ? 'Nombre del cliente requerido' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailCustomerController,
          label: 'Email del Cliente',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isNotEmpty == true && !GetUtils.isEmail(value!)) {
              return 'Email inválido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return _buildSection(
      title: 'Estado y Tipo de Proyecto',
      icon: Icons.settings,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedStatus,
          decoration: InputDecoration(
            labelText: 'Estado del Proyecto',
            labelStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.flag_outlined, color: Colors.grey.shade400),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue.shade400),
            ),
          ),
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(color: Colors.white),
          items: _statusOptions.map((status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedStatus = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedProjectType,
          decoration: InputDecoration(
            labelText: 'Tipo de Proyecto',
            labelStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.category_outlined, color: Colors.grey.shade400),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue.shade400),
            ),
          ),
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(color: Colors.white),
          items: _projectTypeOptions.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedProjectType = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => Get.back(),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade400,
              side: BorderSide(color: Colors.grey.shade600),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveChanges,
            icon: _isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
            label: Text(_isLoading ? 'Guardando...' : 'Guardar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade400, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.blue.shade400,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade400),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              surface: const Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
      case 'en progreso':
        return Colors.green.shade700;
      case 'pausado':
        return Colors.orange.shade700;
      case 'inactivo':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      
      final updateData = <String, dynamic>{};
      
      if (_nameController.text != widget.work.name) {
        updateData['name'] = _nameController.text.trim();
      }
      
      if (_addressController.text != widget.work.address) {
        updateData['direccion'] = _addressController.text.trim(); 
      }
      
      if (_startDateController.text != widget.work.startDate) {
        updateData['startDate'] = _startDateController.text.trim();
      }
      
      if (_endDateController.text != (widget.work.endDate ?? '')) {
        updateData['endDate'] = _endDateController.text.trim();
      }
      
      final newBudget = double.tryParse(_budgetController.text) ?? 0.0;
      if (newBudget != widget.work.budget) {
        updateData['budget'] = newBudget;
      }
      
      if (_workUbicationController.text != widget.work.workUbication) {
        updateData['workUbication'] = _workUbicationController.text.trim();
      }
      
      if (_customerNameController.text != widget.work.customerName) {
        updateData['customerName'] = _customerNameController.text.trim();
      }
      
      if (_emailCustomerController.text != (widget.work.emailCustomer ?? '')) {
        updateData['emailCustomer'] = _emailCustomerController.text.trim();
      }
      
      if (_numberController.text != (widget.work.number ?? '')) {
        updateData['number'] = _numberController.text.trim();
      }
      
      if (_selectedStatus != widget.work.statusWork) {
        updateData['statusWork'] = _selectedStatus;
      }
      
      if (_selectedProjectType != widget.work.projectType) {
        updateData['projectType'] = _selectedProjectType;
      }

      
      if (updateData.isEmpty) {
        _showMessage('No hay cambios para guardar', isError: false);
        return;
      }

      final success = await _controller.updateWork(
        workId: widget.work.id!,
        updateData: updateData,
      );

      if (success) {
        _showMessage('Obra actualizada exitosamente', isError: false);
        Get.back(result: true); 
      } else {
        _showMessage('Error al actualizar obra', isError: true);
      }
    } catch (e) {
      _showMessage('Error inesperado: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message, {required bool isError}) {
    Get.snackbar(
      isError ? 'Error' : 'Éxito',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
    );
  }
}
