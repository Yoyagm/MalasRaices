import 'package:dio/dio.dart';

import '../../../config/api/api_constants.dart';
import '../../../core/models/user_model.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository({required Dio dio}) : _dio = dio;

  Future<UserModel> getProfile() async {
    final response = await _dio.get(ApiConstants.profile);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (phone != null) body['phone'] = phone;

    final response = await _dio.patch(ApiConstants.profile, data: body);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
