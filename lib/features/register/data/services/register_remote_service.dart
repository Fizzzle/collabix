import 'package:collabix/core/auth/models/app_user.dart';
import 'package:collabix/core/auth/services/core_auth_service.dart';
import 'package:collabix/features/register/domain/failures/register_failure.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class RegisterRemoteService {
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });
}

class RegisterRemoteServiceImpl implements RegisterRemoteService {
  RegisterRemoteServiceImpl(this._coreAuthService);

  final CoreAuthService _coreAuthService;

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _coreAuthService.registerWithEmailPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const RegisterFailure('Could not create user account.');
      }

      final user = AppUser(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        description: '',
        dayStreak: 0,
        boardsCreated: 0,
        aiAssists: 0,
      );

      await _coreAuthService.saveUserProfile(user);
      return user;
    } on FirebaseAuthException catch (error) {
      throw RegisterFailure(_mapFirebaseError(error));
    }
  }

  String _mapFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'Email format is invalid.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return error.message ?? 'Registration failed.';
    }
  }
}
