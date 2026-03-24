import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Shared access point to Firebase SDK instances.
abstract class FirebaseService {
  FirebaseAuth get auth;
  FirebaseFirestore get firestore;
}

class FirebaseServiceImpl implements FirebaseService {
  FirebaseServiceImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  FirebaseAuth get auth => _auth;

  @override
  FirebaseFirestore get firestore => _firestore;
}
