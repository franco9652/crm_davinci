import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:crm_app_dv/features/customer/controllers/customer_controller.dart';

class EditCustomerScreen extends StatefulWidget {
  final CustomerModel customer;
  
  const EditCustomerScreen({
    super.key,
    required this.customer,
  });

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<HomeController>();
  

  late final TextEditingController _nameController;
  late final TextEditingController _secondNameController;
  late final TextEditingController _dniController;
  late final TextEditingController _cuitController;
  late final TextEditingController _addressController;
  late final TextEditingController _workDirectionController;
  late final TextEditingController _contactNumberController;
  late final TextEditingController _emailController;
  
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  
  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.customer.name);
    _secondNameController = TextEditingController(text: widget.customer.secondName ?? '');
    _dniController = TextEditingController(text: widget.customer.dni ?? '');
    _cuitController = TextEditingController(text: widget.customer.cuit ?? '');
    _addressController = TextEditingController(text: widget.customer.address ?? '');
    _workDirectionController = TextEditingController(text: widget.customer.workDirection ?? '');
    _contactNumberController = TextEditingController(text: widget.customer.contactNumber);
    _emailController = TextEditingController(text: widget.customer.email);
    _isActive = widget.customer.active ?? true;
  }

  @override
  void dispose() {
    
    _nameController.dispose();
    _secondNameController.dispose();
    _dniController.dispose();
    _cuitController.dispose();
    _addressController.dispose();
    _workDirectionController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
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
        'Editar Cliente',
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
            _buildPersonalInfoSection(),
            const SizedBox(height: 16),
            _buildContactInfoSection(),
            const SizedBox(height: 16),
            _buildAddressSection(),
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
            CircleAvatar(
              backgroundColor: Colors.blue.shade700,
              radius: 30,
              child: Text(
                widget.customer.name.isNotEmpty 
                  ? widget.customer.name[0].toUpperCase()
                  : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.customer.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${widget.customer.id ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isActive ? Colors.green.shade700 : Colors.red.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _isActive ? 'Activo' : 'Inactivo',
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

  
  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Información Personal',
      icon: Icons.person,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _nameController,
                label: 'Nombre *',
                icon: Icons.person_outline,
                validator: (value) => value?.isEmpty == true ? 'Nombre requerido' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _secondNameController,
                label: 'Apellido',
                icon: Icons.person_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _dniController,
                label: 'DNI',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _cuitController,
                label: 'CUIT',
                icon: Icons.business_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  
  Widget _buildContactInfoSection() {
    return _buildSection(
      title: 'Información de Contacto',
      icon: Icons.contact_phone,
      children: [
        _buildTextField(
          controller: _contactNumberController,
          label: 'Teléfono *',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) => value?.isEmpty == true ? 'Teléfono requerido' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email *',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty == true) return 'Email requerido';
            if (!GetUtils.isEmail(value!)) return 'Email inválido';
            return null;
          },
        ),
      ],
    );
  }

  
  Widget _buildAddressSection() {
    return _buildSection(
      title: 'Direcciones',
      icon: Icons.location_on,
      children: [
        _buildTextField(
          controller: _addressController,
          label: 'Dirección Personal',
          icon: Icons.home_outlined,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _workDirectionController,
          label: 'Dirección de Trabajo',
          icon: Icons.work_outline,
          maxLines: 2,
        ),
      ],
    );
  }

 
  Widget _buildStatusSection() {
    return _buildSection(
      title: 'Estado del Cliente',
      icon: Icons.toggle_on,
      children: [
        SwitchListTile(
          title: const Text(
            'Cliente Activo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            _isActive ? 'El cliente está activo en el sistema' : 'El cliente está inactivo',
            style: TextStyle(color: Colors.grey.shade400),
          ),
          value: _isActive,
          onChanged: (value) => setState(() => _isActive = value),
          activeColor: Colors.green.shade600,
          contentPadding: EdgeInsets.zero,
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
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

  
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
     
      final updateData = <String, dynamic>{};
      
      if (_nameController.text != widget.customer.name) {
        updateData['name'] = _nameController.text.trim();
      }
      
      if (_secondNameController.text != (widget.customer.secondName ?? '')) {
        updateData['secondName'] = _secondNameController.text.trim();
      }
      
      if (_dniController.text != (widget.customer.dni ?? '')) {
        updateData['dni'] = _dniController.text.trim();
      }
      
      if (_cuitController.text != (widget.customer.cuit ?? '')) {
        updateData['cuit'] = _cuitController.text.trim();
      }
      
      if (_addressController.text != (widget.customer.address ?? '')) {
        updateData['address'] = _addressController.text.trim();
      }
      
      if (_workDirectionController.text != (widget.customer.workDirection ?? '')) {
        updateData['workDirection'] = _workDirectionController.text.trim();
      }
      
      if (_contactNumberController.text != widget.customer.contactNumber) {
        updateData['contactNumber'] = _contactNumberController.text.trim();
      }
      
      if (_emailController.text != widget.customer.email) {
        updateData['email'] = _emailController.text.trim();
      }
      
      if (_isActive != (widget.customer.active ?? true)) {
        updateData['active'] = _isActive;
      }

      
      if (updateData.isEmpty) {
        _showMessage('No hay cambios para guardar', isError: false);
        return;
      }

      final success = await _controller.updateCustomer(
        customerId: widget.customer.id!,
        updateData: updateData,
      );

      if (success) {
        _showMessage('Cliente actualizado exitosamente', isError: false);
        Get.back(result: true); 
      } else {
        _showMessage('Error al actualizar cliente', isError: true);
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
