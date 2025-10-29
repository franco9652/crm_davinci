import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthService extends GetxService {
  static AuthService get instance => Get.find<AuthService>();
  
 
  final isAuthenticated = false.obs;
  final userRole = ''.obs;
  final userEmail = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadAuthState();
  }

  
  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasToken = prefs.containsKey('auth_token');
      final role = prefs.getString('user_role') ?? '';
      final email = prefs.getString('user_email') ?? '';
      
      const allowedRoles = {'Admin', 'Customer', 'Employee'};
      
      isAuthenticated.value = hasToken && allowedRoles.contains(role);
      userRole.value = role;
      userEmail.value = email;
      
      print('🔐 Auth state loaded: authenticated=${isAuthenticated.value}, role=$role');
    } catch (e) {
      print('❌ Error loading auth state: $e');
      isAuthenticated.value = false;
    }
  }

  
  Future<void> handleTokenExpired() async {
    try {
      print('🚨 Token expired - clearing session');
      
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_role');
      await prefs.remove('user_email');
      
     
      isAuthenticated.value = false;
      userRole.value = '';
      userEmail.value = '';
      
      
      Get.snackbar(
        'Sesión Expirada',
        'Tu sesión ha expirado. Serás redirigido al login.',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );
      
      
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAllNamed('/login');
      });
      
    } catch (e) {
      print('❌ Error handling token expiration: $e');
     
      Get.offAllNamed('/login');
    }
  }


  Future<void> setAuthenticated(String token, String role, String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_role', role);
      await prefs.setString('user_email', email);
      
      isAuthenticated.value = true;
      userRole.value = role;
      userEmail.value = email;
      
      print('✅ User authenticated: role=$role, email=$email');
    } catch (e) {
      print('❌ Error setting authentication: $e');
    }
  }

  
  Future<void> logout() async {
    try {
      print('🚪 User logout initiated');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_role');
      await prefs.remove('user_email');
      
      isAuthenticated.value = false;
      userRole.value = '';
      userEmail.value = '';
      
      Get.offAllNamed('/login');
    } catch (e) {
      print('❌ Error during logout: $e');
      Get.offAllNamed('/login'); 
    }
  }

  
  bool get isLoggedIn {
    return isAuthenticated.value && userRole.value.isNotEmpty;
  }


  String get currentRole => userRole.value;

  
  String get currentEmail => userEmail.value;
}
