import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabix/core/auth/models/app_user.dart';
import 'package:collabix/core/firebase/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class CoreAuthService {
  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
  });

  Future<UserCredential> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<User?> registerWithGoogle();

  Future<void> saveUserProfile(AppUser user);
}

class CoreAuthServiceImpl implements CoreAuthService {
  CoreAuthServiceImpl(this._firebaseService);

  static const String _googleServerClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  final FirebaseService _firebaseService;

  @override
  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _firebaseService.auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> loginWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _firebaseService.auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<User?> registerWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: _googleServerClientId.isEmpty
            ? null
            : _googleServerClientId,
      );

      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCred = await _firebaseService.auth.signInWithCredential(
        credential,
      );

      final user = userCred.user;

      if (user == null) {
        throw Exception('Google sign in failed');
      }

      await saveUserProfile(
        AppUser(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          description: '',
          dayStreak: 0,
          boardsCreated: 0,
          aiAssists: 0,
        ),
      );

      return user;
    } on FirebaseAuthException {
      rethrow;
    } on FirebaseException {
      rethrow;
    }
  }

  @override
  Future<void> saveUserProfile(AppUser user) {
    return _firebaseService.firestore.collection('users').doc(user.uid).set({
      ...user.toFirestoreMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
