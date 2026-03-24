import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabix/core/auth/models/app_user.dart';
import 'package:collabix/core/firebase/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class CoreAuthService {
  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
  });

  Future<UserCredential> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<void> saveUserProfile(AppUser user);
}

class CoreAuthServiceImpl implements CoreAuthService {
  CoreAuthServiceImpl(this._firebaseService);

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
  Future<void> saveUserProfile(AppUser user) {
    return _firebaseService.firestore.collection('users').doc(user.uid).set({
      ...user.toFirestoreMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
