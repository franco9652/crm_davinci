import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crm_app_dv/features/customer/controllers/customer_controller.dart';
import 'package:crm_app_dv/features/customer/presentation/create_customer_page.dart';
import 'package:crm_app_dv/features/customer/presentation/customer_info_screen.dart';
import 'package:crm_app_dv/features/customer/presentation/widgets/customer_actions_widget.dart';
import 'package:crm_app_dv/features/customer/presentation/widgets/delete_customer_dialog.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:crm_app_dv/shared/widgets/modern_pagination_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax/iconsax.dart';

class HomePageCustomer extends StatelessWidget {
  final HomeController controller = Get.put(HomeController(
    repository: Get.find(),
  ));

  HomePageCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clientes',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1B1926),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Iconsax.search_normal, color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF2A2937),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.customers.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final displayedCustomers = controller.searchQuery.isEmpty 
                  ? controller.customers 
                  : controller.filteredCustomers;

              if (displayedCustomers.isEmpty) {
                return Center(
                  child: Text(
                    controller.noClientMessage.value,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: displayedCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = displayedCustomers[index];
                        return _buildCustomerCard(customer);
                      },
                    ),
                  ),
                  _buildPaginationControls(),
                ],
              );
            }),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1B1926),
      floatingActionButton: _buildModernFAB(),
      
    );
  }

  Widget _buildModernFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'createCustomer',
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () => Get.to(() =>  CreateCustomerPage()),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
    return Card(
      color: const Color(0xFF242038),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          if (customer.userId != null && customer.userId!.isNotEmpty) {
            Get.to(() => CustomerInfoScreen(userId: customer.userId!));
          } else {
            CustomerDialogs.showCustomerInfo(customer);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade700,
                    radius: 20,
                    child: Text(
                      customer.name.isNotEmpty 
                        ? customer.name[0].toUpperCase()
                        : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${customer.name} ${customer.secondName ?? ''}".trim(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          customer.email,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  CustomerActionsWidget(
                    customer: customer,
                    onCustomerUpdated: () => controller.fetchCustomers(),
                    onCustomerDeleted: () => controller.fetchCustomers(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(Icons.phone_outlined, 
                    color: Colors.grey.shade400, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      customer.contactNumber,
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (customer.active ?? true) 
                        ? Colors.green.shade700 
                        : Colors.red.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (customer.active ?? true) ? 'Activo' : 'Inactivo',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (customer.address?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, 
                      color: Colors.grey.shade400, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        customer.address!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Obx(() => Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      child: ModernPaginationWidget(
        currentPage: controller.currentPage.value,
        totalPages: controller.totalPages.value,
        onPageChanged: (page) => controller.goToPage(page),
        isLoading: controller.isLoading.value,
      ),
    ));
  }

  Future<void> _openWhatsApp(String contactNumber) async {
    
    final formattedPhone = _formatPhoneForWhatsApp(contactNumber);
    
    print('🔗 Número original: $contactNumber');
    print('🔗 Número formateado: $formattedPhone');
    
    final url = "https://wa.me/$formattedPhone";
    
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        Get.snackbar("Error", "No se puede abrir WhatsApp");
      }
    } catch (e) {
      Get.snackbar("Error", "Error al abrir WhatsApp: $e");
    }
  }


  String _formatPhoneForWhatsApp(String rawPhone) {
    
    String digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    
    
    if (digits.length == 10 && digits.startsWith('11')) {
      
      return '549$digits';
    }
    
   
    if (digits.startsWith('549')) {
      return digits;
    }
    
   
    if (digits.startsWith('54') && digits.length >= 12) {
      
      return '549${digits.substring(2)}';
    }
    
   
    if (digits.startsWith('54') && digits.length >= 10) {
      final withoutCountryCode = digits.substring(2);
      if (withoutCountryCode.startsWith('11')) {
        return '549$withoutCountryCode';
      }
    }
    
    
    return digits;
  }

  void _sendEmail(String email) async {
    final url = "mailto:$email";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Get.snackbar("Error", "No se puede abrir el correo");
    }
  }
}
