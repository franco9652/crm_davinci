import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../login/controllers/auth_remote_data_source.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final AuthRemoteDataSource _authRemoteDataSource = AuthRemoteDataSource(http.Client());

  // 🚫 **Rate Limiting Variables**
  var isRateLimited = false.obs;
  var cooldownSeconds = 0.obs;
  Timer? _cooldownTimer;

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

    if (isRateLimited.value) return;
    
    try {
      isLoading.value = true;
      
      final response = await _authRemoteDataSource.sendPasswordRecoveryEmail(emailController.text);
      
      // 🚫 **Manejo de Rate Limiting**
      if (response['rateLimited'] == true) {
        isRateLimited.value = true;
        cooldownSeconds.value = response['cooldownTime'] ?? 300;
        _startCooldown();
        Get.snackbar(
          'Límite alcanzado',
          response['message'] ?? 'Espera antes de solicitar otro correo',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return;
      }
      
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

  // 🚫 **Sistema de Cooldown**
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
    emailController.dispose();
    _cooldownTimer?.cancel();
    super.onClose();
  }
}
