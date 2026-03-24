import 'package:collabix/core/auth/models/app_user.dart';
import 'package:collabix/core/auth/services/core_auth_service.dart';
import 'package:collabix/core/firebase/firebase_service.dart';
import 'package:collabix/features/login/domain/failures/login_failure.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class LoginRemoteService {
  Future<AppUser> login({
    required String email,
    required String password,
  });
}

class LoginRemoteServiceImpl implements LoginRemoteService {
  LoginRemoteServiceImpl(this._coreAuthService, this._firebaseService);

  final CoreAuthService _coreAuthService;
  final FirebaseService _firebaseService;

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _coreAuthService.loginWithEmailPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const LoginFailure('Could not login user.');
      }

      final userDoc = await _firebaseService.firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      final data = userDoc.data() ?? const <String, dynamic>{};
      return AppUser(
        uid: firebaseUser.uid,
        name: (data['name'] as String?) ?? (firebaseUser.displayName ?? ''),
        email: (data['email'] as String?) ?? (firebaseUser.email ?? email),
        description: (data['description'] as String?) ?? '',
        dayStreak: (data['dayStreak'] as int?) ?? 0,
        boardsCreated: (data['boardsCreated'] as int?) ?? 0,
        aiAssists: (data['aiAssists'] as int?) ?? 0,
      );
    } on FirebaseAuthException catch (error) {
      throw LoginFailure(_mapFirebaseError(error));
    }
  }

  String _mapFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'Email format is invalid.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return error.message ?? 'Login failed.';
    }
  }
}
