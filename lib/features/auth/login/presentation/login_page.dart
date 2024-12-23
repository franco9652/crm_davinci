import 'package:crm_app_dv/app_routes.dart';
import 'package:crm_app_dv/features/auth/login/controllers/auth_remote_data_source.dart';
import 'package:crm_app_dv/features/auth/login/controllers/auth_repository_impl.dart';
import 'package:crm_app_dv/features/auth/login/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatelessWidget {
  final LoginController controller = Get.put(
      LoginController(AuthRepositoryImpl(AuthRemoteDataSource(http.Client()))));
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Fondo oscuro
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Bienvenido a ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Color(0xFFFF13BD), Color(0xFFFF8329)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'CRM',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Contenedor del formulario
              Container(
                width: 320,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF3B82F6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título del formulario
                    const Text(
                      'Ingresar a Lotus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email Input
                    Obx(() => _buildInputField(
                          icon: Icons.email_outlined,
                          hintText: 'Email address',
                          onChanged: (value) => controller.email.value = value,
                          errorText: controller.emailError.value,
                        )),
                    const SizedBox(height: 20),

                    // Password Input con el botón "ojito"
                    Obx(() => _buildInputField(
                          icon: Icons.lock_outline,
                          hintText: 'Password',
                          obscureText: !controller.isPasswordVisible.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white70,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                          onChanged: (value) =>
                              controller.password.value = value,
                          errorText: controller.passwordError.value,
                        )),

                    const SizedBox(height: 10),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {}, // Agregar funcionalidad aquí
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.login,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF13BD), Color(0xFFFF8329)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Link de registro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.toNamed(AppRoutes.register);
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Divider
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    child: Divider(color: Colors.grey, thickness: 1),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'O',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Container(
                    width: 150,
                    child: Divider(color: Colors.grey, thickness: 1),
                  ),
                ],
              ),

              

              const SizedBox(height: 100),

              // Footer
              const Text(
                '© 2025 CRM\nTerminos & Condiciones | Politica de privacidad | Legal',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String hintText,
    required Function(String) onChanged,
    bool obscureText = false,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: onChanged,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white70),
            suffixIcon: suffixIcon,
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blueAccent),
            ),
            errorText: errorText == '' ? null : errorText,
            errorStyle: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}
