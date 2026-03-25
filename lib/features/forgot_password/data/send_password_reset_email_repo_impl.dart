import 'package:collabix/core/firebase/firebase_service.dart';
import 'package:collabix/features/forgot_password/domain/repository/send_password_reset_email_repo.dart';

class SendPasswordResetEmailRepoImpl
    implements SendPasswordResetEmailRepository {
  final FirebaseService _firebaseService;
  SendPasswordResetEmailRepoImpl(this._firebaseService);

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    return _firebaseService.auth.sendPasswordResetEmail(email: email);
  }
}
