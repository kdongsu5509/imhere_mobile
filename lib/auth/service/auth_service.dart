import 'package:dio/dio.dart';
import 'package:iamhere/auth/service/auth_service_interface.dart';
import 'package:iamhere/auth/service/dto/login_request_dto.dart';
import 'package:iamhere/auth/service/token_storage_service.dart';
import 'package:iamhere/common/result/error_analyst.dart';
import 'package:iamhere/common/result/result_message.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthService implements AuthServiceInterface {
  final Dio _dio;
  final TokenStorageService _tokenStorage;

  final _loginApi = '/api/v1/auth/login';

  AuthService(this._dio, this._tokenStorage);

  @override
  sendIdTokenToServer(String idToken) async {
    try {
      final response = await _dio.post(
        _loginApi,
        data: LoginReqeustDto(provider: 'KAKAO', idToken: idToken).toJson(),
      );

      // 서버 응답에서 JWT 토큰 추출 및 저장
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final accessToken = data['accessToken'] as String?;
        final refreshToken = data['refreshToken'] as String?;

        if (accessToken != null) {
          await _tokenStorage.saveAccessToken(accessToken);
        }

        if (refreshToken != null) {
          await _tokenStorage.saveRefreshToken(refreshToken);
        }
      }
    } on DioException catch (e, stack) {
      ErrorAnalyst.log(ResultMessage.dioException.toString(), stack);
      throw Exception(ResultMessage.dioException);
    }
  }
}
