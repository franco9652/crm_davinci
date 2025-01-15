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

  Future<List<WorkModel>> getWorksByUserId(String userId) async {
  return await remoteDataSource.getWorksByUserId(userId);
}

}
