import 'package:collabix/core/auth/models/app_user.dart';
import 'package:collabix/features/register/data/services/register_remote_service.dart';
import 'package:collabix/features/register/domain/repositories/register_repository.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  RegisterRepositoryImpl(this._remoteService);

  final RegisterRemoteService _remoteService;

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _remoteService.register(name: name, email: email, password: password);
  }
}
