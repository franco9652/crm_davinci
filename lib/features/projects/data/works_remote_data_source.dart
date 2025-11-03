import 'dart:convert';
import 'package:crm_app_dv/core/contants/app_constants.dart';
import 'package:crm_app_dv/core/utils/http_helper.dart';
import 'package:crm_app_dv/features/projects/controllers/works_controller.dart';
import 'package:crm_app_dv/models/work_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

      if (jsonResponse.containsKey('totalPages')) {
        final totalPagesFromServer = jsonResponse['totalPages'] as int;
        final workController = Get.find<WorkController>();
        workController.totalPages.value = totalPagesFromServer;
        workController.hasNextPage.value = page < totalPagesFromServer;
      }

      return (jsonResponse['works'] as List)
          .map((data) => WorkModel.fromJson(data))
          .toList();
    } else {
      throw Exception('Error al obtener los proyectos');
    }
  }

  Future<void> createWork(WorkModel work) async {
    try {
      print('🔄 Creando obra: ${work.name}');
      
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      
      final workData = work.toJson();
      workData.remove('_id'); 
      
      if (workData['userId'] is String) {
        workData['userId'] = [workData['userId']];
      } else if (workData['userId'] is List && (workData['userId'] as List).isEmpty) {
        workData.remove('userId');
      }
      
      if (workData['statusWork'] != null) {
        workData['statusWork'] = workData['statusWork'].toString().toLowerCase();
      }
      if (workData['projectType'] != null) {
        workData['projectType'] = workData['projectType'].toString().toLowerCase();
      }
      
      print('📤 Datos enviados: $workData');
      
      final response = await HttpHelper.post(
        '${AppConstants.baseUrl}/workCreate',
        workData,
        headers: headers,
      );
      
      if (response['success'] == true) {
        print('✅ Obra creada exitosamente');
        return;
      } else {
        final errorMsg = response['error'] ?? 'Error desconocido al crear la obra';
        print('❌ Error creando obra: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Excepción al crear obra: $e');
      throw Exception('Error al crear la obra: ${e.toString()}');
    }
  }

  Future<List<WorkModel>> getWorksByUserId(String customerId) async {
    final url = '${AppConstants.baseUrl}/workgetbycustomerid/$customerId';

    print(" WorkRemoteDataSource: Haciendo petición a: $url");

    final response = await client.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    print(" WorkRemoteDataSource: Status: ${response.statusCode}");
    print(" WorkRemoteDataSource: Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return (jsonResponse['works'] as List)
          .map((data) => WorkModel.fromJson(data))
          .toList();
    } else if (response.statusCode == 404) {
      print(" No se encontraron trabajos para este cliente.");
      return [];
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

  Future<List<WorkModel>> getWorksByCustomerId(String customerId) async {
    final response = await client.get(
      Uri.parse('${AppConstants.baseUrl}/worksbycustomerid/$customerId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return (jsonResponse['works'] as List)
          .map((data) => WorkModel.fromJson(data))
          .toList();
    } else if (response.statusCode == 404) {
      return []; 
    } else {
      throw Exception('Error al obtener los trabajos del cliente');
    }
  }

 
  Future<List<WorkModel>> getWorksByCustomerUserId(String userId) async {
    final url = '${AppConstants.baseUrl}/getcustomersbyid/$userId';
    final response = await client.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final Map<String, dynamic> customer = (jsonResponse is Map && jsonResponse['customer'] is Map)
          ? Map<String, dynamic>.from(jsonResponse['customer'])
          : Map<String, dynamic>.from(jsonResponse as Map);

      final dynamic worksField = customer['worksActive'] ?? customer['works'] ?? [];
      final List<String> workIds = (worksField is List)
          ? worksField.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList()
          : <String>[];

      final List<WorkModel> works = [];
      for (final id in workIds) {
        try {
          final w = await getWorkById(id);
          works.add(w);
        } catch (_) {
          
        }
      }
      return works;
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Error al obtener cliente por userId');
    }
  }

  Future<WorkModel> getWorkById(String workId) async {
    final response = await client.get(
      Uri.parse('${AppConstants.baseUrl}/workgetbyid/$workId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print(jsonResponse);
      return WorkModel.fromJson(jsonResponse['work']);
    } else {
      throw Exception('Error al obtener los detalles del trabajo');
    }
  }

  
  Future<WorkModel> updateWork({
    required String workId,
    Map<String, dynamic>? updateData,
  }) async {
    try {
      print('🔄 Actualizando obra: $workId');
      print('📝 Datos a actualizar: $updateData');
      
      final response = await HttpHelper.patch(
        '${AppConstants.baseUrl}/workUpdate/$workId',
        updateData ?? {},
      );
      
      if (response['success'] == true) {
        final workData = response['data'] as Map<String, dynamic>;
        final updatedWork = WorkModel.fromJson(workData);
        print('✅ Obra actualizada: ${updatedWork.name}');
        return updatedWork;
      } else {
        final errorMsg = response['error'] ?? 'Error desconocido al actualizar obra';
        print('❌ Error actualizando obra: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Excepción al actualizar obra: $e');
      throw Exception('Error al actualizar la obra: ${e.toString()}');
    }
  }

 
  Future<WorkModel> updateWorkComplete({
    required String workId, 
    required Map<String, dynamic> workData,
  }) async {
    try {
      print('🔄 Actualizando obra completa: $workId');
      
      final response = await HttpHelper.put(
        '${AppConstants.baseUrl}/workPut/$workId',
        workData,
      );
      
      if (response['success'] == true) {
        final updatedWorkData = response['data'] as Map<String, dynamic>;
        final updatedWork = WorkModel.fromJson(updatedWorkData);
        print('✅ Obra actualizada completamente: ${updatedWork.name}');
        return updatedWork;
      } else {
        final errorMsg = response['error'] ?? 'Error desconocido al actualizar obra';
        print('❌ Error actualizando obra completa: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Excepción al actualizar obra completa: $e');
      throw Exception('Error al actualizar la obra: ${e.toString()}');
    }
  }

  
  Future<void> deleteWork(String workMongoId) async {
    try {
      print('🗑️ Eliminando obra con MongoDB ID: $workMongoId');
      final url = '${AppConstants.baseUrl}/workDelete/$workMongoId';
      print('🌐 URL de eliminación: $url');
      
      final response = await HttpHelper.delete(url);
      print('📡 Respuesta del servidor: $response');
      
      if (response['success'] == true) {
        print('✅ Obra eliminada correctamente');
        return;
      } else {
        final errorMsg = response['error'] ?? 'Error desconocido al eliminar obra';
        print('❌ Error eliminando obra: $errorMsg');
        print('📋 Respuesta completa: $response');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Excepción al eliminar obra: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        throw Exception('Error de conexión: Verifica tu conexión a internet');
      } else if (e.toString().contains('404')) {
        throw Exception('Obra no encontrada en el servidor (ID: $workMongoId)');
      } else if (e.toString().contains('500')) {
        throw Exception('Error interno del servidor');
      } else {
        throw Exception('Error al eliminar la obra: ${e.toString()}');
      }
    }
  }


  Map<String, dynamic> workModelToUpdateMap(WorkModel work) {
    return {
      'name': work.name,
      'direccion': work.address, //TODO: backend usa 'direccion'Y mi modelo usa 'address'
      'startDate': work.startDate,
      'endDate': work.endDate,
      'budget': work.budget,
      'employeeInWork': work.employeeInWork,
      'documents': work.documents,
      'number': work.number,
      'customerName': work.customerName,
      'emailCustomer': work.emailCustomer,
      'statusWork': work.statusWork,
      'workUbication': work.workUbication,
      'projectType': work.projectType,
    };
  }
}
