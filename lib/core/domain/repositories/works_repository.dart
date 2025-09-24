import 'package:crm_app_dv/features/projects/data/works_remote_data_source.dart';
import 'package:crm_app_dv/models/work_model.dart';

class WorkRepository {
  final WorkRemoteDataSource remoteDataSource;

  WorkRepository(this.remoteDataSource);

  Future<List<WorkModel>> getAllWorks(int page, int limit) {
    return remoteDataSource.getAllWorks(page, limit);
  }

  Future<void> createWork(WorkModel work) {
    return remoteDataSource.createWork(work);
  }

 Future<List<WorkModel>> getWorksByCustomerId(String customerId) async {
   print("🟢work repo Llamando a getWorksByUserId en WorkRepository con customerId: $customerId");
  return await remoteDataSource.getWorksByCustomerId(customerId);
}

Future<WorkModel> getWorkById(String? workId) async {
  if (workId == null || workId.isEmpty) {
    throw Exception("El ID del trabajo es nulo o vacío");
  }
  
  return await remoteDataSource.getWorkById(workId);
}


  Future<List<WorkModel>> getWorksByUserId(String userId) async {
    return await remoteDataSource.getWorksByUserId(userId);
  }

  /// Actualizar obra usando PATCH (actualización parcial) - Senior approach
  Future<WorkModel> updateWork({
    required String workId,
    required Map<String, dynamic> updateData,
  }) async {
    return await remoteDataSource.updateWork(
      workId: workId,
      updateData: updateData,
    );
  }

  /// Actualizar obra usando PUT (actualización completa) - Senior approach
  Future<WorkModel> updateWorkComplete({
    required String workId,
    required Map<String, dynamic> workData,
  }) async {
    return await remoteDataSource.updateWorkComplete(
      workId: workId,
      workData: workData,
    );
  }

  /// Eliminar obra - Senior approach
  Future<void> deleteWork(String workAutoIncrementId) async {
    return await remoteDataSource.deleteWork(workAutoIncrementId);
  }

  /// Helper para convertir WorkModel a Map para actualización
  Map<String, dynamic> workModelToUpdateMap(WorkModel work) {
    return remoteDataSource.workModelToUpdateMap(work);
  }
}
