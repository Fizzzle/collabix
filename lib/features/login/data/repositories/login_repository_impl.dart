import 'package:collabix/core/auth/models/app_user.dart';
import 'package:collabix/features/login/data/services/login_remote_service.dart';
import 'package:collabix/features/login/domain/repositories/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  LoginRepositoryImpl(this._remoteService);

  final LoginRemoteService _remoteService;

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) {
    return _remoteService.login(email: email, password: password);
  }
}
