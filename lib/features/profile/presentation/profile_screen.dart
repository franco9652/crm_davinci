import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../auth/login/controllers/login_controller.dart';
import '../../auth/change_password/presentation/change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1B1926),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Email Card - FIXED VERSION
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF323438),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Usuario actual:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                  loginController.email.value.isNotEmpty 
                      ? loginController.email.value 
                      : 'usuario@example.com',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => const ChangePasswordScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text('Cambiar contraseña', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          // Settings - FIXED TITLES
          const SizedBox(height: 24),
          _buildSectionHeader('SOPORTE'),
          _buildSimpleItem('Ayuda', 'Contactar', onTap: () => _launchWhatsApp(context)),

          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: () {
                loginController.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSimpleItem(String title, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF323438),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.blueAccent[200],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    const phone = '5491158800708';
    const message = 'Hola necesito ayuda con el CRM';

    final whatsappUri = Uri.parse(
        'whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}');
    final waMeUri = Uri.parse(
        'https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        return;
      }
      // Para enlaces http/https, algunos dispositivos retornan false en canLaunchUrl,
      // probamos directamente con launchUrl y capturamos errores.
      if (await canLaunchUrl(waMeUri) || true) {
        final launched = await launchUrl(waMeUri, mode: LaunchMode.externalApplication);
        if (launched) return;
      }
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No se pudo abrir WhatsApp'),
          content: const Text('Verificá que WhatsApp esté instalado o intenta nuevamente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No se pudo abrir WhatsApp'),
          content: Text('Error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }
}
