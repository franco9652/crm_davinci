import 'package:crm_app_dv/app_routes.dart';
import 'package:crm_app_dv/core/domain/repositories/budget_repository.dart';
import 'package:crm_app_dv/core/domain/repositories/customer_repository.dart';
import 'package:crm_app_dv/core/domain/repositories/works_repository.dart';
import 'package:crm_app_dv/features/auth/login/controllers/auth_remote_data_source.dart';
import 'package:crm_app_dv/features/auth/login/controllers/auth_repository_impl.dart';
import 'package:crm_app_dv/features/auth/login/controllers/login_controller.dart';
import 'package:crm_app_dv/features/budgets/controllers/budget_controller.dart';
import 'package:crm_app_dv/features/budgets/data/budget_data_source.dart';
import 'package:crm_app_dv/features/customer/controllers/customer_remote_data_source.dart';
import 'package:crm_app_dv/features/projects/controllers/works_controller.dart';
import 'package:crm_app_dv/features/projects/data/works_remote_data_source.dart';
import 'package:crm_app_dv/navigation/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos las dependencias
  final client = http.Client();
  final customerRemoteDataSource = CustomerRemoteDataSource(client);
  final customerRepository = CustomerRepository(customerRemoteDataSource);

  final workRemoteDataSource = WorkRemoteDataSource(client);
  final workRepository = WorkRepository(workRemoteDataSource);

  final dataSource = BudgetDataSource();
  final budgetRepository = BudgetRepository(dataSource);

   // Auth Repositories
  final authRemoteDataSource = AuthRemoteDataSource(client);
  final authRepository = AuthRepositoryImpl(authRemoteDataSource);

  // Registramos las dependencias con Get
  Get.put(customerRemoteDataSource); // Remote Data Source
  Get.put(customerRepository); // Repository
  Get.put(workRemoteDataSource); // Work Remote Data Source
  Get.put(workRepository); // Work Repository
  Get.put(BudgetController(budgetRepository)); // Budget Controller

  Get.put(WorkController(
      customerRepository: customerRepository,
      workRemoteDataSource: workRemoteDataSource,
));
 // Work Controller

  Get.put(authRepository); // Auth Repository
  Get.put(LoginController(authRepository)); // Login Controller

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.containsKey('auth_token');

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRM App',
      theme: ThemeData(
        textTheme: GoogleFonts.openSansTextTheme(),
      ),
      initialRoute: isLoggedIn ? AppRoutes.mainNavigation : AppRoutes.login,
      getPages: [
        GetPage(name: '/', page: () => MainNavigationScreen()),
        ...AppRoutes.pages,
      ],
    );
  }
}
