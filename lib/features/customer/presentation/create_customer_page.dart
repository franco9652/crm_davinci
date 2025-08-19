import 'package:crm_app_dv/features/customer/controllers/customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CreateCustomerPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
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
      backgroundColor: const Color(0xFF1B1926),
      appBar: AppBar(
        title: const Text("Crear Cliente", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B1926),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField(
                label: "Nombre",
                controller: nameController,
                hint: "Ej. Juan Pérez",
                icon: Icons.person,
              ),
              _buildInputField(
                label: "DNI",
                controller: dniController,
                hint: "Ej. 12345678",
                icon: Icons.badge,
                isNumber: true,
              ),
              _buildInputField(
                label: "CUIT",
                controller: cuitController,
                hint: "Ej. 20123456789",
                icon: Icons.credit_card,
                isNumber: true,
              ),
              _buildInputField(
                label: "CUIL",
                controller: cuilController,
                hint: "Ej. 20123456789",
                icon: Icons.credit_card_outlined,
                isNumber: true,
              ),
              _buildInputField(
                label: "Dirección",
                controller: addressController,
                hint: "Ej. Calle Falsa 123",
                icon: Icons.home,
              ),
              _buildInputField(
                label: "Dirección Laboral",
                controller: workDirectionController,
                hint: "Ej. Avenida Siempre Viva 742",
                icon: Icons.work,
              ),
              _buildInputField(
                label: "Número de Contacto",
                controller: contactNumberController,
                hint: "Ej. +541112345678",
                icon: Icons.phone,
                isNumber: true,
              ),
              _buildInputField(
                label: "Email",
                controller: emailController,
                hint: "Ej. ejemplo@correo.com",
                icon: Icons.email,
                isEmail: true,
              ),
              _buildInputField(
                label: "Contraseña",
                controller: passwordController,
                hint: "Ej. contraseña123",
                icon: Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final customerController = Get.find<HomeController>();
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8329),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Crear Cliente",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumber = false,
    bool isEmail = false,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber
            ? TextInputType.number
            : isEmail
                ? TextInputType.emailAddress
                : TextInputType.text,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF242038),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Este campo es obligatorio";
          }
          if (isEmail && !GetUtils.isEmail(value)) {
            return "Por favor, introduce un email válido";
          }
          return null;
        },
      ),
    );
  }
}
