import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../login/controllers/auth_remote_data_source.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final AuthRemoteDataSource _authRemoteDataSource = AuthRemoteDataSource(http.Client());

  Future<void> sendRecoveryEmail() async {
    if (emailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Por favor ingresa tu correo electrónico',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      isLoading.value = true;
      
      final response = await _authRemoteDataSource.sendPasswordRecoveryEmail(emailController.text);
      
      if (response['success'] == true) {
        Get.snackbar(
          'Éxito',
          response['message'] ?? 'Se ha enviado un correo de recuperación',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'No se pudo enviar el correo de recuperación',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Ocurrió un error inesperado: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
