import 'package:crm_app_dv/features/customer/presentation/home_customer.dart';
import 'package:crm_app_dv/features/projects/presentation/works_page.dart';
import 'package:crm_app_dv/navigation/controller/main_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';


class MainNavigationScreen extends StatelessWidget {
  final MainNavigationController controller = Get.put(MainNavigationController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children:  [
             HomePageCustomer(),
             WorkListPage()
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Color(0xff1B1926),

            unselectedItemColor: const Color(0xFFA7A7CC),
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Iconsax.people), label: 'Clientes'),
              BottomNavigationBarItem(icon: Icon(Iconsax.ticket), label: 'Proyectos'),
              BottomNavigationBarItem(icon: Icon(Iconsax.wallet), label: 'Presupuestos'),
              BottomNavigationBarItem(icon: Icon(Iconsax.personalcard), label: 'Configuracion'),
            
            ],
          ),
        ));
  }
}
