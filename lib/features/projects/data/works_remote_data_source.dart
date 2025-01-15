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

    if (response.statusCode == 201 || response.statusCode == 200) {
      // Éxito: No lances excepción, solo imprime el resultado
      print('Proyecto creado exitosamente: ${response.body}');
    } else {
      // Manejo de errores
      final errorResponse = json.decode(response.body);
      final errorMessage =
          errorResponse['message'] ?? 'Error desconocido al crear el proyecto';
      throw Exception(errorMessage);
    }
  }

Future<List<WorkModel>> getWorksByUserId(String userId) async {
  final response = await client.get(
    Uri.parse('${AppConstants.baseUrl}/worksbyuserid/$userId'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return (jsonResponse['works'] as List)
        .map((data) => WorkModel.fromJson(data))
        .toList();
  } else if (response.statusCode == 404) {
    return []; // Devuelve una lista vacía si no hay trabajos
  } else {
    throw Exception('Error al obtener los trabajos del usuario');
  }
}


  Future<List<WorkModel>> fetchAllWorks({int page = 1, int limit = 10}) async {
    try {
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
        throw Exception('Error al obtener la lista de proyectos');
      }
    } catch (e) {
      throw Exception('Error en fetchAllWorks: $e');
    }
  }
}
