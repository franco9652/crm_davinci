

import 'package:crm_app_dv/features/auth/login/presentation/login_page.dart';
import 'package:crm_app_dv/features/budgets/presentation/budget_list_screen.dart';
import 'package:crm_app_dv/features/customer/presentation/home_customer.dart';
import 'package:crm_app_dv/features/profile/presentation/profile_screen.dart';
import 'package:crm_app_dv/features/projects/presentation/works_page.dart';
import 'package:crm_app_dv/navigation/main_navigation.dart';
import 'package:get/get.dart';

class AppRoutes {
  // Rutas principales del BottomNavigationBar
  static const login = '/login';
  static const register = '/register';
  static const mainNavigation = '/main-navigation';
  static const home = '/customers';
  static const altaCustomer = '/alta-customer';
  static const projects = '/projects';
  static const walletHome = '/alta-projects';
  static const budgets = '/budgets';
  static const profile = '/profile';
  

  // Todas las rutas registradas
  static final List<GetPage> pages = [
    GetPage(name: mainNavigation, page: () => MainNavigationScreen()),
    // Páginas principales del BottomNavigationBar
    GetPage(name: login, page: () => LoginPage()),
    GetPage(name: home, page: () => HomePageCustomer()),
    GetPage(name: projects, page: () => WorkListPage()),
    GetPage(name: budgets, page: () => CreateBudgetScreen()),
    GetPage(name: profile, page: () => ProfileScreen()),
    
  ];
}
