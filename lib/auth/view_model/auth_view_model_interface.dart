import 'package:iamhere/common/result/error_message.dart';
import 'package:iamhere/common/result/result.dart';

abstract class AuthViewModelInterface {
  Future<Result<ErrorMessage>> handleKakaoLogin();
  Future<Result<ErrorMessage>> requestFCMTokenAndSendToServer();
}
