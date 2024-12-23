import 'package:crm_app_dv/core/domain/repositories/auth_repository.dart';

import 'auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<String> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }
}
