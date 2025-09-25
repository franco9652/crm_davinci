import 'package:crm_app_dv/features/customer/controllers/customer_info_controller.dart';
import 'package:crm_app_dv/features/projects/controllers/works_controller.dart';
import 'package:crm_app_dv/features/customer/presentation/widgets/customer_actions_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class CustomerInfoScreen extends StatelessWidget {
  final String userId;

  const CustomerInfoScreen({Key? key, required this.userId}) : super(key: key);

  String _formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final CustomerInfoController customerController = Get.put(
      CustomerInfoController(customerRepository: Get.find()),
    );

    final WorkController workController = Get.put(
      WorkController(
        customerRepository: Get.find(),
        workRemoteDataSource: Get.find(),
        workRepository: Get.find(),
      ),
    );

    customerController.fetchCustomerInfo(userId);

    // Asegurarse de obtener el customerId correcto (_id en MongoDB)
    ever(customerController.customer, (_) {
      final String customerId = customerController.customer.value?.id ?? userId;
      workController.fetchWorksByCustomer(customerId);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Obx(() {
        if (customerController.isLoadingCustomer.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          );
        }

        final customer = customerController.customer.value;

        if (customer == null) {
          return const Center(
            child: Text(
              'No se encontró información para este cliente',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // App Bar moderno con gradiente
            SliverAppBar(
              expandedHeight: 220,
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
                        Color(0xFF1E293B),
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
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Cliente desde ${_formatDateTime(customer.createdAt.toString())}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CustomerActionsWidget(
                                customer: customer,
                                onCustomerUpdated: () => customerController.fetchCustomerInfo(userId),
                                onCustomerDeleted: () => Get.back(),
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
            
            // Contenido principal
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Acciones rápidas
                    _buildQuickActionsCard(context, customer),
                    const SizedBox(height: 20),
                    
                    // Información de contacto
                    _buildInfoSection('Información de Contacto', [
                      _buildModernInfoRow(Icons.phone, 'Teléfono', customer.contactNumber),
                      _buildModernInfoRow(Icons.email, 'Email', customer.email),
                      _buildModernInfoRow(Icons.location_on, 'Dirección', customer.address),
                    ]),
                    const SizedBox(height: 20),
                    
                    // Información personal
                    _buildInfoSection('Información Personal', [
                      _buildModernInfoRow(Icons.badge, 'DNI', customer.dni),
                      _buildModernInfoRow(Icons.business, 'CUIT', customer.cuit),
                      _buildModernInfoRow(Icons.account_box, 'CUIL', customer.cuil),
                      if (customer.workDirection.isNotEmpty)
                        _buildModernInfoRow(Icons.work, 'Dirección de Trabajo', customer.workDirection),
                    ]),
                    const SizedBox(height: 20),
                    
                    // Proyectos del cliente
                    _buildProjectsSection(workController),
                    
                    const SizedBox(height: 100), // Espacio extra al final
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // 🚀 **Tarjeta de Acciones Rápidas**
  Widget _buildQuickActionsCard(BuildContext context, customer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flash_on, color: Color(0xFF6366F1), size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Acciones Rápidas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionButton(
                Icons.email,
                'Email',
                const Color(0xFF06B6D4),
                () => _sendEmail(context, customer.email),
              ),
              _buildQuickActionButton(
                Icons.phone,
                'Llamar',
                const Color(0xFF10B981),
                () => _makeCall(context, customer.contactNumber),
              ),
              _buildQuickActionButton(
                Icons.message,
                'WhatsApp',
                const Color(0xFF22C55E),
                () => _launchWhatsApp(context, customer.contactNumber, customer.name),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🎯 **Botón de Acción Rápida**
  Widget _buildQuickActionButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🏗️ **Sección de Información Moderna**
  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // 📋 **Fila de Información Moderna**
  Widget _buildModernInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🏢 **Sección de Proyectos**
  Widget _buildProjectsSection(WorkController workController) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                child: const Icon(Icons.business, color: Color(0xFFF59E0B), size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Proyectos del Cliente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (workController.isLoadingWorks.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                ),
              );
            }

            if (workController.worksByCustomer.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B7280).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.work_off, color: Color(0xFF6B7280), size: 24),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No hay proyectos disponibles',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: workController.worksByCustomer.map((work) => _buildProjectItem(work)).toList(),
            );
          }),
        ],
      ),
    );
  }

  // 🏗️ **Item de Proyecto**
  Widget _buildProjectItem(work) {
    Color statusColor;
    switch (work.statusWork.toLowerCase()) {
      case 'activo':
      case 'en progreso':
        statusColor = const Color(0xFF10B981);
        break;
      case 'pausado':
        statusColor = const Color(0xFFF59E0B);
        break;
      case 'inactivo':
        statusColor = const Color(0xFFEF4444);
        break;
      default:
        statusColor = const Color(0xFF6B7280);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  work.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  work.statusWork,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white.withOpacity(0.5), size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  work.address,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendEmail(BuildContext context, String email) async {
    // 1) Intent Gmail (Android/iOS) -> 2) mailto
    final gmailUri = Uri.parse('googlegmail://co?to=${Uri.encodeComponent(email)}');
    final mailtoUri = Uri(scheme: 'mailto', path: email);
    // 3) Gmail web compose (fallback navegador)
    final gmailWebUri = Uri.parse('https://mail.google.com/mail/?view=cm&fs=1&to=${Uri.encodeComponent(email)}');

    try {
      if (await canLaunchUrl(gmailUri)) {
        final ok = await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
        if (ok) return;
      }
      // Algunos dispositivos devuelven false en canLaunchUrl. Intentamos directo.
      final okMail = await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
      if (okMail) return;

      // Fallback al navegador (compositor de Gmail web)
      final okWeb = await launchUrl(gmailWebUri, mode: LaunchMode.externalApplication);
      if (okWeb) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No se pudo abrir el correo'),
          content: Text('Intentá con la app de Gmail instalada y configurada o accedé vía navegador.\nDirección: $email'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar')),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No se pudo abrir el correo'),
          content: Text('Error: $e'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar')),
          ],
        ),
      );
    }
  }

  void _makeCall(BuildContext context, String phoneNumber) async {
    final normalized = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: normalized); // abre marcador (no requiere permiso)
    final Uri phonePromptUri = Uri.parse('telprompt:$normalized'); // iOS alternativo
    try {
      // Intentamos directo sin chequear canLaunch por dispositivos que devuelven false
      var ok = await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      if (!ok && await canLaunchUrl(phonePromptUri)) {
        ok = await launchUrl(phonePromptUri, mode: LaunchMode.externalApplication);
      }
      if (ok) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No se pudo realizar la llamada'),
          content: Text('Número: $normalized'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar')),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No se pudo realizar la llamada'),
          content: Text('Error: $e'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar')),
          ],
        ),
      );
    }
  }

  Future<void> _launchWhatsApp(BuildContext context, String phoneNumber, String name) async {
    final message = 'Hola $name';
    // Normalizamos número básico: quitamos espacios y caracteres no numéricos
    final normalized = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    final whatsappUri = Uri.parse(
        'whatsapp://send?phone=$normalized&text=${Uri.encodeComponent(message)}');
    final waMeUri = Uri.parse(
        'https://wa.me/$normalized?text=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        return;
      }
      // Fallback a wa.me (navegador o app)
      final launched = await launchUrl(waMeUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw 'No se pudo abrir el enlace wa.me';
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No se pudo abrir WhatsApp'),
          content: Text('Número: $normalized\nError: $e'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar')),
          ],
        ),
      );
    }
  }
}
