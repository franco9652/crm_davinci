import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../login/controllers/auth_remote_data_source.dart';

class ResetPasswordController extends GetxController {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final AuthRemoteDataSource _authRemoteDataSource = AuthRemoteDataSource(http.Client());
  final String? token = Get.parameters['token'];

  void togglePasswordVisibility() => isPasswordVisible.value = !isPasswordVisible.value;
  void toggleConfirmPasswordVisibility() => 
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  Future<void> resetPassword() async {
    if (token == null) {
      Get.snackbar(
        'Error',
        'Token de recuperación inválido',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _authRemoteDataSource.resetPassword(token!, passwordController.text);
      Get.snackbar(
        'Éxito',
        'Contraseña restablecida correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo restablecer la contraseña',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
