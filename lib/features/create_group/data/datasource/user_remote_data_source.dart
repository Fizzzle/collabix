// data/datasources/user_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabix/core/auth/models/app_user.dart';

abstract class UserRemoteDataSource {
  Future<List<AppUser>> fetchUsersByNickname(String query);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<AppUser>> fetchUsersByNickname(String query) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return [];

    try {
      final lowerFieldSnapshot = await firestore
          .collection('users')
          .where('nameLower', isGreaterThanOrEqualTo: normalizedQuery)
          .where('nameLower', isLessThanOrEqualTo: '$normalizedQuery\uf8ff')
          .limit(20)
          .get();

      final users = lowerFieldSnapshot.docs
          .map((doc) => AppUser.fromJson(doc.data()))
          .where(
            (user) => user.name.toLowerCase().contains(normalizedQuery),
          )
          .toList();

      if (users.isNotEmpty) return users;
    } catch (_) {
      // Fallback to legacy schema without `nameLower`.
    }

    final fallbackSnapshot = await firestore.collection('users').limit(100).get();
    return fallbackSnapshot.docs
        .map((doc) => AppUser.fromJson(doc.data()))
        .where((user) => user.name.toLowerCase().contains(normalizedQuery))
        .take(20)
        .toList();
  }
}
