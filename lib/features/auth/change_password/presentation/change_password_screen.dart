import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        slivers: [
          
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1E293B),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1), 
                      Color(0xFF8B5CF6), 
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.lock_reset,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cambiar Contraseña',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Actualiza tu contraseña de acceso',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  _buildModernSection(
                    title: 'Contraseña Actual',
                    icon: Icons.lock_outline,
                    color: const Color(0xFFEF4444),
                    children: [
                      Obx(() => _buildModernPasswordField(
                            controller: controller.currentPasswordController,
                            label: 'Contraseña Actual',
                            hint: 'Ingresa tu contraseña actual',
                            icon: Icons.lock,
                            color: const Color(0xFFEF4444),
                            obscureText: controller.isCurrentPasswordObscured.value,
                            onToggleVisibility: controller.toggleCurrentPasswordVisibility,
                          )),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                 
                  _buildModernSection(
                    title: 'Nueva Contraseña',
                    icon: Icons.lock_open,
                    color: const Color(0xFF10B981),
                    children: [
                      Obx(() => _buildModernPasswordField(
                            controller: controller.newPasswordController,
                            label: 'Nueva Contraseña',
                            hint: 'Ingresa tu nueva contraseña',
                            icon: Icons.vpn_key,
                            color: const Color(0xFF10B981),
                            obscureText: controller.isNewPasswordObscured.value,
                            onToggleVisibility: controller.toggleNewPasswordVisibility,
                          )),
                      const SizedBox(height: 16),
                      Obx(() => _buildModernPasswordField(
                            controller: controller.confirmPasswordController,
                            label: 'Confirmar Nueva Contraseña',
                            hint: 'Vuelve a ingresar tu nueva contraseña',
                            icon: Icons.verified_user,
                            color: const Color(0xFF06B6D4),
                            obscureText: controller.isConfirmPasswordObscured.value,
                            onToggleVisibility: controller.toggleConfirmPasswordVisibility,
                          )),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  
                  _buildSecurityTips(),
                  
                  const SizedBox(height: 30),
                  
                  
                  Obx(() => _buildModernChangeButton(controller)),
                  
                  const SizedBox(height: 40), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildModernSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildModernPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            suffixIcon: InkWell(
              onTap: onToggleVisibility,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF374151).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF334155).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

 
  Widget _buildSecurityTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Consejos de Seguridad',
                style: TextStyle(
                  color: Color(0xFFF59E0B),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSecurityTip(Icons.check_circle_outline, 'Usa al menos 8 caracteres'),
          _buildSecurityTip(Icons.check_circle_outline, 'Incluye mayúsculas y minúsculas'),
          _buildSecurityTip(Icons.check_circle_outline, 'Agrega números y símbolos'),
          _buildSecurityTip(Icons.check_circle_outline, 'Evita información personal'),
        ],
      ),
    );
  }

  
  Widget _buildSecurityTip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF10B981), size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildModernChangeButton(ChangePasswordController controller) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: controller.isLoading.value
              ? [const Color(0xFF6B7280), const Color(0xFF6B7280)]
              : [const Color(0xFF10B981), const Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: controller.isLoading.value
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.isLoading.value ? null : controller.changePassword,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.security, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Cambiar Contraseña',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
