import 'package:dio/dio.dart';

import '../../../config/api/api_constants.dart';
import '../../../core/models/user_model.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository({required Dio dio}) : _dio = dio;

  Future<({UserModel user, String accessToken, String refreshToken})>
      register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    final response = await _dio.post(ApiConstants.register, data: {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
    });

    final data = response.data as Map<String, dynamic>;
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }

  Future<({UserModel user, String accessToken, String refreshToken})> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });

    final data = response.data as Map<String, dynamic>;
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }

  Future<({String accessToken, String refreshToken})> refreshToken(
    String token,
  ) async {
    final response = await _dio.post(ApiConstants.refresh, data: {
      'refreshToken': token,
    });

    final data = response.data as Map<String, dynamic>;
    return (
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }

  Future<UserModel> getProfile() async {
    final response = await _dio.get(ApiConstants.profile);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
