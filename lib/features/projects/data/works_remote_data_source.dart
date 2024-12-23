import 'dart:convert';
import 'package:crm_app_dv/core/contants/app_constants.dart';
import 'package:crm_app_dv/models/work_model.dart';
import 'package:http/http.dart' as http;

class WorkRemoteDataSource {
  final http.Client client;

  WorkRemoteDataSource(this.client);

Future<List<WorkModel>> getAllWorks(int page, int limit) async {
  final response = await client.get(
    Uri.parse('${AppConstants.baseUrl}/works?page=$page&limit=$limit'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);

    List<WorkModel> works = (jsonResponse['works'] as List)
        .map((data) => WorkModel.fromJson(data))
        .toList();
    return works;
  } else {
    throw Exception('Error al obtener los proyectos');
  }
}


  Future<void> createWork(WorkModel work) async {
    final response = await client.post(
      Uri.parse('${AppConstants.baseUrl}/workCreate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(work.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception(
          'Error al crear el proyecto: ${jsonDecode(response.body)['message']}');
    }
  }
}
