import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../login/controllers/auth_remote_data_source.dart';

class ChangePasswordController extends GetxController {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  final RxBool isLoading = false.obs;
  final AuthRemoteDataSource _authRemoteDataSource = AuthRemoteDataSource(http.Client());

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  bool validateForm() {
    if (currentPasswordController.text.isEmpty) {
      _showError('Por favor ingrese su contraseña actual');
      return false;
    }
    
    if (newPasswordController.text.isEmpty) {
      _showError('Por favor ingrese su nueva contraseña');
      return false;
    }
    
    if (newPasswordController.text.length < 6) {
      _showError('La nueva contraseña debe tener al menos 6 caracteres');
      return false;
    }
    
    if (newPasswordController.text != confirmPasswordController.text) {
      _showError('Las contraseñas no coinciden');
      return false;
    }
    
    return true;
  }

  Future<void> changePassword() async {
    if (!validateForm()) return;
    
    try {
      isLoading.value = true;
      
      final response = await _authRemoteDataSource.changePassword(
        currentPasswordController.text,
        newPasswordController.text
      );
      
      if (response['success']) {
        Get.back(); // Volver a la pantalla anterior
        Get.snackbar(
          'Éxito',
          response['message'] ?? 'Contraseña actualizada correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
        );
      } else {
        _showError(response['message'] ?? 'Error al cambiar la contraseña');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red[400],
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 5),
    );
  }
}
