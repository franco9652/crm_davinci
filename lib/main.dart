import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_routes.dart';
import 'core/services/notification_service.dart';
import 'core/services/auth_service.dart';
import 'package:crm_app_dv/core/services/notification_service.dart';
import 'package:crm_app_dv/features/customer/controllers/customer_remote_data_source.dart';
import 'package:crm_app_dv/core/domain/repositories/customer_repository.dart';
import 'package:crm_app_dv/features/projects/data/works_remote_data_source.dart';
import 'package:crm_app_dv/core/domain/repositories/works_repository.dart';
import 'package:crm_app_dv/features/budgets/data/budget_data_source.dart';
import 'package:crm_app_dv/core/domain/repositories/budget_repository.dart';
import 'package:crm_app_dv/features/budgets/controllers/budget_controller.dart';
import 'package:crm_app_dv/features/auth/login/controllers/auth_remote_data_source.dart';
import 'package:crm_app_dv/features/auth/login/controllers/auth_repository_impl.dart';
import 'package:crm_app_dv/features/auth/login/controllers/login_controller.dart';
import 'package:crm_app_dv/features/projects/controllers/works_controller.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final client = http.Client();
  final customerRemoteDataSource = CustomerRemoteDataSource(client);
  final customerRepository = CustomerRepository(customerRemoteDataSource);

  final workRemoteDataSource = WorkRemoteDataSource(client);
  final workRepository = WorkRepository(workRemoteDataSource);

  final budgetRemoteDataSource = BudgetRemoteDataSource(client); 
  final budgetRepository = BudgetRepository(budgetRemoteDataSource); 

  // Auth Repositories
  final authRemoteDataSource = AuthRemoteDataSource(client);
  final authRepository = AuthRepositoryImpl(authRemoteDataSource);

  // 🔹 Primero, registramos `BudgetRemoteDataSource` en GetX
  Get.put(budgetRemoteDataSource); 
  Get.put(budgetRepository); 
  Get.put(BudgetController(budgetRemoteDataSource: Get.find())); 

  // Registramos las demás dependencias en el orden correcto
  Get.put(customerRemoteDataSource);
  Get.put(customerRepository);
  Get.put(workRemoteDataSource);
  Get.put(workRepository);
  Get.put(WorkController(
    customerRepository: customerRepository,
    workRemoteDataSource: workRemoteDataSource,
    workRepository: workRepository,
  ));

  Get.put(authRemoteDataSource);
  Get.put(authRepository);
  Get.put(LoginController(authRepository));

  // 🔐 **Inicializar AuthService**
  Get.put(AuthService(), permanent: true);

  final prefs = await SharedPreferences.getInstance();
  final bool hasToken = prefs.containsKey('auth_token');
  final role = (prefs.getString('user_role') ?? '').trim();
  const allowedRoles = {'Admin', 'Customer', 'Employee'};
  final bool isLoggedIn = hasToken && allowedRoles.contains(role);

  // Inicializar servicio de notificaciones
  await NotificationService.initialize();

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
      getPages: AppRoutes.pages,
    );
  }
}
