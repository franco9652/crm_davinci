
import 'package:crm_app_dv/features/customer/controllers/customer_remote_data_source.dart';
import 'package:crm_app_dv/models/budget_model.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:crm_app_dv/models/work_model.dart';

class CustomerRepository {
  final CustomerRemoteDataSource dataSource;
  
  CustomerRepository(this.dataSource);

  /// Crear nuevo cliente
  Future<void> createCustomer(CustomerModel customer) async {
    await dataSource.createCustomer(customer);
  }

  /// Obtener todos los clientes con paginación
  Future<Map<String, dynamic>> fetchCustomers(int page) async {
    return await dataSource.getAllCustomers(page);
  }

  /// Obtener cliente por ID
  Future<Map<String, dynamic>> getCustomerById(String userId) async {
    return await dataSource.getCustomerById(userId);
  }

  /// Obtener trabajos por cliente
  Future<List<WorkModel>> getWorksByUserId(String customerId) async {
    return await dataSource.getWorksByUserId(customerId);
  }

  /// Obtener presupuestos por cliente
  Future<List<BudgetModel>> getBudgetsByCustomer(String customerId) async {
    return await dataSource.getBudgetsByCustomerId(customerId);
  }

  /// Actualizar cliente (Senior approach)
  Future<CustomerModel> updateCustomer({
    required String customerId,
    required Map<String, dynamic> updateData,
  }) async {
    return await dataSource.updateCustomer(
      customerId: customerId,
      updateData: updateData,
    );
  }

  /// Eliminar cliente (Senior approach)
  Future<void> deleteCustomer(String customerId) async {
    return await dataSource.deleteCustomer(customerId);
  }
}
