import 'package:crm_app_dv/app_routes.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_repository_impl.dart';

class LoginController extends GetxController {
  final AuthRepositoryImpl authRepository;

  LoginController(this.authRepository);

  var email = ''.obs;
  var password = ''.obs;
  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  var emailError = ''.obs;
  var passwordError = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadUserEmail();
  }
  
  // Cargar el email guardado
  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      email.value = savedEmail;
    }
  }

  Future<void> login() async {
    if (!_validateForm()) return;

    isLoading.value = true;
    try {
      final token = await authRepository.login(email.value, password.value);

      // Guardar el token y email en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_email', email.value); // Guardar el email

      Get.offAllNamed(AppRoutes.mainNavigation); // Redirigir al listado de clientes
    } catch (e) {
      Get.snackbar('Error', 'Credenciales incorrectas');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token'); // Verifica si existe un token guardado
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Elimina el token guardado
    Get.offAllNamed('/login'); // Redirige al login
  }

  bool _validateForm() {
    emailError.value = '';
    passwordError.value = '';

    if (!GetUtils.isEmail(email.value)) {
      emailError.value = 'Por favor, introduce un correo válido.';
    }

    if (password.value.length < 6) {
      passwordError.value = 'La contraseña debe tener al menos 6 caracteres.';
    }

    return emailError.value.isEmpty && passwordError.value.isEmpty;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
}
