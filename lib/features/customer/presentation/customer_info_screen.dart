import 'package:crm_app_dv/features/customer/controllers/customer_info_controller.dart';
import 'package:crm_app_dv/features/projects/controllers/works_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerInfoScreen extends StatelessWidget {
  final String userId;

  const CustomerInfoScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CustomerInfoController customerController = Get.put(
      CustomerInfoController(customerRepository: Get.find()),
    );

    final WorkController workController = Get.put(
      WorkController(
        customerRepository: Get.find(),
        workRemoteDataSource: Get.find(),
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
                      'Se registró el: ${customer.createdAt}', // Ajustar formato si es necesario
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(
                            Icons.email, 'Email', () => _sendEmail(customer.email)),
                        _buildActionButton(Icons.phone, 'Teléfono',
                            () => _makeCall(customer.contactNumber)),
                        _buildActionButton(Icons.calendar_today, 'Agenda', () {}),
                        _buildActionButton(Icons.note, 'Notas', () {}),
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

  void _sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      Get.snackbar('Error', 'No se pudo abrir el correo');
    }
  }

  void _makeCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      Get.snackbar('Error', 'No se pudo realizar la llamada');
    }
  }
}
