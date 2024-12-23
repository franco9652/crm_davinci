import 'package:crm_app_dv/features/customer/controllers/customer_controller.dart';
import 'package:crm_app_dv/features/customer/presentation/create_customer_page.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';


class HomePageCustomer extends StatelessWidget {
  final HomeController controller = Get.put(HomeController(
    repository: Get.find(),
  ));

  HomePageCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF1B1926),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.customers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.customers.isEmpty) {
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
                itemCount: controller.customers.length,
                itemBuilder: (context, index) {
                  final customer = controller.customers[index];
                  return _buildCustomerCard(customer);
                },
              ),
            ),
            _buildPaginationControls(),
          ],
        );
      }),
      backgroundColor: const Color(0xFF1B1926),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => CreateCustomerPage());
        },
        backgroundColor: const Color(0xFFFF8329),
        child: const Icon(Icons.add, color: Colors.white),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${customer.name} ${customer.secondName}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  customer.address,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Tel: ${customer.contactNumber}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _openWhatsApp(customer.contactNumber),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Iconsax.message),
                  label: const Text("WhatsApp"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _sendEmail(customer.email),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4380FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.email),
                  label: const Text("Email"),
                ),
              ],
            ),
          ],
        ),
      ),
      
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      color: const Color(0xFF1B1926),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: controller.currentPage.value > 1
                ? () => controller.goToPage(controller.currentPage.value - 1)
                : null,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            disabledColor: Colors.grey,
          ),
          ...List.generate(controller.totalPages.value, (index) {
            final pageIndex = index + 1;
            final isSelected = pageIndex == controller.currentPage.value;
            return GestureDetector(
              onTap: () => controller.goToPage(pageIndex),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF8329) : const Color(0xFF242038),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF4380FF)),
                ),
                child: Text(
                  pageIndex.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
          IconButton(
            onPressed: controller.currentPage.value < controller.totalPages.value
                ? () => controller.goToPage(controller.currentPage.value + 1)
                : null,
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            disabledColor: Colors.grey,
          ),
        ],
      ),
    );
  }

  void _openWhatsApp(String contactNumber) async {
    final url = "https://wa.me/$contactNumber";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Get.snackbar("Error", "No se puede abrir WhatsApp");
    }
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
