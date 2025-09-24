import 'package:crm_app_dv/features/customer/controllers/customer_info_controller.dart';
import 'package:crm_app_dv/features/projects/controllers/works_controller.dart';
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
      appBar: AppBar(
        title: const Text(
          'Información del Cliente',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1B1926),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (customerController.isLoadingCustomer.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final customer = customerController.customer.value;

        if (customer == null) {
          return const Center(
            child: Text(
              'No se encontró información para este cliente',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                color: const Color(0xFF1B1926),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade800,
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      customer.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Se registró el: ${_formatDateTime(customer.createdAt.toString())}',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(
                            Icons.email, 'Email', () => _sendEmail(context, customer.email)),
                        _buildActionButton(Icons.phone, 'Teléfono',
                            () => _makeCall(context, customer.contactNumber)),
                        _buildActionButton(
                            Icons.message, 'WhatsApp',
                            () => _launchWhatsApp(context, customer.contactNumber, customer.name)),
                      ],
                    ),
                  ],
                ),
              ),

              // Contact Info Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF323438),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF323438)),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información de Contacto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffBDBEC0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(Icons.phone, color: Color(0xffBDBEC0)),
                        title: Text(customer.contactNumber,
                            style: const TextStyle(color: Color(0xffBDBEC0))),
                      ),
                      ListTile(
                        leading: const Icon(Icons.email, color: Color(0xffBDBEC0)),
                        title: Text(customer.email,
                            style: const TextStyle(color: Color(0xffBDBEC0))),
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_on, color: Color(0xffBDBEC0)),
                        title: Text(customer.address,
                            style: const TextStyle(color: Color(0xffBDBEC0))),
                      ),
                    ],
                  ),
                ),
              ),

              // Active Projects Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF242038),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4380FF)),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Proyectos Activos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        if (workController.isLoadingWorks.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (workController.worksByCustomer.isEmpty) {
                          return const Text(
                            'No hay proyectos activos disponibles en este momento.',
                            style: TextStyle(color: Colors.white70),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: workController.worksByCustomer.length,
                          itemBuilder: (context, index) {
                            final work = workController.worksByCustomer[index];
                            return ListTile(
                              title: Text(work.name,
                                  style: const TextStyle(color: Colors.white)),
                              subtitle: Text(work.address,
                                  style: const TextStyle(color: Colors.white70)),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      backgroundColor: const Color(0xFF1B1926),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF323438),
            child: Icon(icon, color: const Color(0xffBDBEC0)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
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
