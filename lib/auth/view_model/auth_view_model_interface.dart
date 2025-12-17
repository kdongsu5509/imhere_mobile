import 'package:iamhere/common/result/result_message.dart';
import 'package:iamhere/common/result/result.dart';

abstract class AuthViewModelInterface {
  Future<Result<ResultMessage>> handleKakaoLogin();
  Future<Result<ResultMessage>> requestFCMTokenAndSendToServer();
}
