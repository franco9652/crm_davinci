import 'package:crm_app_dv/features/customer/controllers/customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CreateCustomerPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController secondNameController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
   final TextEditingController CuilController = TextEditingController();
  final TextEditingController cuitController = TextEditingController();
  final TextEditingController cuilController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController workDirectionController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: CustomScrollView(
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
                                Icons.person_add,
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
                                    'Crear Cliente',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Completa la información del nuevo cliente',
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
                      'Información Personal',
                      Icons.person,
                      const Color(0xFF6366F1),
                      [
                        _buildModernTextField(
                          nameController,
                          "Nombre Completo",
                          Icons.person,
                          hint: "Ej. Juan Pérez",
                        ),
                        _buildModernTextField(
                          dniController,
                          "DNI",
                          Icons.badge,
                          hint: "Ej. 12345678",
                          isNumeric: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    _buildFormSection(
                      'Información Fiscal',
                      Icons.account_balance,
                      const Color(0xFF8B5CF6),
                      [
                        _buildModernTextField(
                          cuitController,
                          "CUIT",
                          Icons.credit_card,
                          hint: "Ej. 20123456789 (11 dígitos)",
                          isNumeric: true,
                          maxLength: 11,
                          isCuitCuil: true,
                          cuitCuilType: "CUIT",
                        ),
                        _buildModernTextField(
                          cuilController,
                          "CUIL",
                          Icons.credit_card_outlined,
                          hint: "Ej. 20123456789 (11 dígitos)",
                          isNumeric: true,
                          maxLength: 11,
                          isCuitCuil: true,
                          cuitCuilType: "CUIL",
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    _buildFormSection(
                      'Direcciones',
                      Icons.location_on,
                      const Color(0xFF10B981),
                      [
                        _buildModernTextField(
                          addressController,
                          "Dirección Personal",
                          Icons.home,
                          hint: "Ej. Calle Falsa 123",
                        ),
                        _buildModernTextField(
                          workDirectionController,
                          "Dirección Laboral",
                          Icons.work,
                          hint: "Ej. Avenida Siempre Viva 742",
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    _buildFormSection(
                      'Contacto y Acceso',
                      Icons.contact_phone,
                      const Color(0xFFF59E0B),
                      [
                        _buildModernTextField(
                          contactNumberController,
                          "Número de Contacto",
                          Icons.phone,
                          hint: "Ej. +541112345678",
                          isNumeric: true,
                        ),
                        _buildModernTextField(
                          emailController,
                          "Email",
                          Icons.email,
                          hint: "Ej. ejemplo@correo.com",
                          isEmail: true,
                        ),
                        _buildModernTextField(
                          passwordController,
                          "Contraseña",
                          Icons.lock,
                          hint: "Mín 8 chars, 1 mayúscula, 1 símbolo",
                          isPassword: true,
                          isPasswordField: true,
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
      ),
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
    String? hint,
    bool isNumeric = false,
    bool isEmail = false,
    bool isPassword = false,
    bool isPasswordField = false,
    int? maxLength,
    bool isCuitCuil = false,
    String? cuitCuilType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric
            ? TextInputType.number
            : isEmail
                ? TextInputType.emailAddress
                : TextInputType.text,
        obscureText: isPassword,
        maxLength: maxLength,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 12,
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
          suffixIcon: isPasswordField
              ? Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.security, color: Color(0xFFEF4444), size: 18),
                )
              : isCuitCuil
                  ? Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.verified_user, color: Color(0xFF10B981), size: 18),
                    )
                  : null,
          filled: true,
          fillColor: const Color(0xFF0F172A),
          counterText: maxLength != null ? null : "",
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Este campo es obligatorio";
          }
          if (isEmail && !GetUtils.isEmail(value)) {
            return "Por favor, introduce un email válido";
          }
          if (isCuitCuil && value.length != 11) {
            return "Debe tener exactamente 11 dígitos";
          }
          if (isCuitCuil && !RegExp(r'^\d+$').hasMatch(value)) {
            return "Solo debe contener números";
          }
          if (isCuitCuil && cuitCuilType == "CUIT") {
            final validPrefixes = ['20', '23', '24', '27', '30', '33', '34'];
            final prefix = value.substring(0, 2);
            if (!validPrefixes.contains(prefix)) {
              return "Prefijo inválido. Use: 20, 23, 24, 27, 30, 33, 34";
            }
          }
          if (isCuitCuil && cuitCuilType == "CUIL") {
            final validPrefixes = ['20', '23', '24', '27'];
            final prefix = value.substring(0, 2);
            if (!validPrefixes.contains(prefix)) {
              return "Prefijo inválido. Use: 20, 23, 24, 27";
            }
          }
          if (isPasswordField) {
            if (value.length < 8) {
              return "Mínimo 8 caracteres";
            }
            if (!RegExp(r'[A-Z]').hasMatch(value)) {
              return "Debe tener al menos 1 mayúscula";
            }
            if (!RegExp(r'[!@#$%^&*()_\-+={}[\]|:;"<>,.?/~`]').hasMatch(value)) {
              return "Debe tener al menos 1 símbolo especial";
            }
          }
          return null;
        },
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
      child: GetBuilder<HomeController>(
        builder: (customerController) => Obx(() => ElevatedButton.icon(
          onPressed: customerController.isCreating.value ? null : () async {
            if (_formKey.currentState!.validate()) {
              await customerController.createCustomer(
                name: nameController.text,
                secondName: secondNameController.text,
                dni: dniController.text,
                cuit: cuitController.text,
                cuil: cuilController.text,
                address: addressController.text,
                workDirection: workDirectionController.text,
                contactNumber: contactNumberController.text,
                email: emailController.text,
                password: passwordController.text,
              );
            }
          },
          icon: customerController.isCreating.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.person_add, color: Colors.white, size: 20),
          label: Text(
            customerController.isCreating.value ? 'Creando...' : 'Crear Cliente',
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
      ),
    );
  }
}
