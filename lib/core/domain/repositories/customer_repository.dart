
import 'package:crm_app_dv/features/customer/controllers/customer_remote_data_source.dart';
import 'package:crm_app_dv/models/budget_model.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:crm_app_dv/models/work_model.dart';

class CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;
  
  CustomerRepository(this.remoteDataSource);

  // Crear un cliente
  Future<void> createCustomer(CustomerModel customer) async {
    await remoteDataSource.createCustomer(customer);
  }

  // Obtener todos los clientes con paginación
  Future<Map<String, dynamic>> fetchCustomers(int page) async {
    return await remoteDataSource.getAllCustomers(page);
  }

Future<CustomerModel> getCustomerById(String userId) async {
  final response = await remoteDataSource.getCustomerById(userId);
  return CustomerModel.fromJson(response); // Convierte el JSON al modelo
}

Future<List<WorkModel>> getWorksByCustomer(String customerId) async {
   print("🟢 cutomer repo Llamando a getWorksByUserId en WorkRepository con customerId: $customerId");
  return await remoteDataSource.getWorksByUserId(customerId);
}

Future<List<BudgetModel>> getBudgetsByCustomer(String customerId) async {
  return await remoteDataSource.getBudgetsByCustomerId(customerId);
}



}
