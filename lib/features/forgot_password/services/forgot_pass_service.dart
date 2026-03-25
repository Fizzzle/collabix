import 'package:collabix/features/forgot_password/domain/entity/forgot_pass_request.dart';
import 'package:collabix/features/forgot_password/domain/usecase/send_password_reser_email_use_case.dart';

class ForgotPasswordService {
  final SendPasswordResetEmailUseCase _sendEmail;

  ForgotPasswordService(this._sendEmail);

  Future<void> resetPassword(ForgotPasswordRequest request) async {
    await _sendEmail(request.email);
  }
}
