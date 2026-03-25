import 'package:collabix/features/forgot_password/domain/repository/send_password_reset_email_repo.dart';

class SendPasswordResetEmailUseCase {
  final SendPasswordResetEmailRepository _sendPasswordResetEmailRepository;
  SendPasswordResetEmailUseCase(this._sendPasswordResetEmailRepository);

  Future<void> call(String email) async {
    if (email.isEmpty) throw Exception("Email cannot be empty");
    return _sendPasswordResetEmailRepository.sendPasswordResetEmail(email);
  }
}
