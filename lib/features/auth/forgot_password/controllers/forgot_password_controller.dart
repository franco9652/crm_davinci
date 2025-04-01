import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../login/controllers/auth_remote_data_source.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final AuthRemoteDataSource _authRemoteDataSource = AuthRemoteDataSource(http.Client());

  Future<void> sendRecoveryEmail() async {
    try {
      isLoading.value = true;
      await _authRemoteDataSource.sendPasswordRecoveryEmail(emailController.text);
      Get.snackbar(
        'Éxito',
        'Se ha enviado un correo de recuperación',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo enviar el correo de recuperación',
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
