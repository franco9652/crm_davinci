
import 'package:crm_app_dv/features/customer/controllers/customer_remote_data_source.dart';
import 'package:crm_app_dv/models/customer_model.dart';

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
}
