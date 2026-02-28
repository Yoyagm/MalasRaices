import 'package:dio/dio.dart';

import '../../../config/api/api_constants.dart';
import '../../../core/models/property_model.dart';

class PropertiesRepository {
  final Dio _dio;

  PropertiesRepository({required Dio dio}) : _dio = dio;

  Future<List<PropertyModel>> getMyProperties() async {
    final response = await _dio.get(ApiConstants.properties);
    final list = response.data as List<dynamic>;
    return list
        .map((item) => PropertyModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<PropertyModel> getById(String id) async {
    final response = await _dio.get(ApiConstants.propertyById(id));
    return PropertyModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PropertyModel> create(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.properties, data: data);
    return PropertyModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PropertyModel> update(String id, Map<String, dynamic> data) async {
    final response =
        await _dio.patch(ApiConstants.propertyById(id), data: data);
    return PropertyModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deactivate(String id) async {
    await _dio.delete(ApiConstants.propertyById(id));
  }
}
