import 'dart:async';
import 'package:crm_app_dv/app_routes.dart';
import 'package:crm_app_dv/core/services/auth_service.dart';
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

 
  var isRateLimited = false.obs;
  var cooldownSeconds = 0.obs;
  Timer? _cooldownTimer;
  
  @override
  void onInit() {
    super.onInit();
    _loadUserEmail();
  }
  
 
  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      email.value = savedEmail;
    }
  }

  Future<void> login() async {
    if (!_validateForm() || isRateLimited.value) return;

    isLoading.value = true;
    try {
      final result = await authRepository.login(email.value, password.value);
      
    
      if (result['rateLimited'] == true) {
        isRateLimited.value = true;
        cooldownSeconds.value = result['cooldownTime'] ?? 300;
        _startCooldown();
        Get.snackbar(
          'Demasiados intentos',
          result['error'] ?? 'Espera antes de intentar nuevamente',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return;
      }

      
      if (result['success'] != true) {
        Get.snackbar('Error', result['error'] ?? 'Credenciales incorrectas');
        return;
      }

      
      final token = result['token'] as String?;
      final roleRaw = (result['role'] as String? ?? '').trim();
      final roleLower = roleRaw.toLowerCase();
      
      
      String canonicalRole = '';
      if (['admin','administrator','administrador'].contains(roleLower)) {
        canonicalRole = 'Admin';
      } else if (['customer','cliente','user','usuario'].contains(roleLower)) {
        canonicalRole = 'Customer';
      } else if (['employee','empleado','staff'].contains(roleLower)) {
        canonicalRole = 'Employee';
      }

      if (token == null || token.isEmpty) {
        throw Exception('Token inválido');
      }

      
      const allowedRoles = {'Admin', 'Customer', 'Employee'};
      if (!allowedRoles.contains(canonicalRole)) {
        Get.snackbar('Acceso denegado', 'Tu rol ("$roleRaw") no tiene acceso a la app.');
        return; 
      }

      
      if (Get.isRegistered<AuthService>()) {
        await AuthService.instance.setAuthenticated(token, canonicalRole, email.value);
      } else {
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_email', email.value);
        await prefs.setString('user_role', canonicalRole);
      }

      Get.offAllNamed(AppRoutes.mainNavigation);
    } catch (e) {
      Get.snackbar('Error', 'Error de conexión: $e');
    } finally {
      isLoading.value = false;
    }
  }

 
  void _startCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      cooldownSeconds.value--;
      if (cooldownSeconds.value <= 0) {
        isRateLimited.value = false;
        timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    super.onClose();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final hasToken = prefs.containsKey('auth_token');
    final role = (prefs.getString('user_role') ?? '').trim();
    const allowedRoles = {'Admin', 'Customer', 'Employee'};
    return hasToken && allowedRoles.contains(role);
  }

  Future<void> logout() async {
    if (Get.isRegistered<AuthService>()) {
      await AuthService.instance.logout();
    } else {
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_role');
      await prefs.remove('user_email');
      Get.offAllNamed('/login');
    }
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
