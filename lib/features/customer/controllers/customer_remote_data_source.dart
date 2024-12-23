import 'dart:convert';

import 'package:crm_app_dv/core/contants/app_constants.dart';
import 'package:crm_app_dv/models/customer_model.dart';
import 'package:http/http.dart' as http;

class CustomerRemoteDataSource {
  final http.Client client;

  CustomerRemoteDataSource(this.client);

 Future<void> createCustomer(CustomerModel customer) async {
  final response = await client.post(
    Uri.parse('${AppConstants.baseUrl}/customerCreate'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(customer.toJson()),
  );

  // Manejar código de éxito no estándar
  if (response.statusCode == 200 || response.statusCode == 201) {
    // Cliente creado correctamente
    return;
  } else if (response.statusCode == 400 || response.statusCode == 409) {
    // Error controlado (por ejemplo, email duplicado)
    final errorResponse = jsonDecode(response.body);
    throw Exception(errorResponse['message'] ?? 'Error desconocido');
  } else {
    // Error no controlado
    throw Exception('Error al dar de alta un cliente: ${response.body}');
  }
}

Future<Map<String, dynamic>> getAllCustomers(int page) async {
  const int limit = 5; // Máximo de clientes por página
  final response = await client.get(
    Uri.parse('${AppConstants.baseUrl}/customers?page=$page&limit=$limit'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);

    final totalPages = jsonResponse['totalPages'];

    List<CustomerModel> customers = (jsonResponse['customers'] as List)
        .map((data) => CustomerModel.fromJson(data))
        .toList();

    return {'customers': customers, 'totalPages': totalPages};
  } else {
    throw Exception('Error al obtener los clientes');
  }
}


}
