import 'package:dio/dio.dart';

import '../../../config/api/api_constants.dart';
import '../../../core/models/property_model.dart';

class FavoritesRepository {
  final Dio _dio;

  FavoritesRepository({required Dio dio}) : _dio = dio;

  Future<List<PropertyModel>> getAll() async {
    final response = await _dio.get(ApiConstants.favorites);
    final list = response.data as List<dynamic>;
    return list
        .map((item) {
          final fav = item as Map<String, dynamic>;
          return PropertyModel.fromJson(fav['property'] as Map<String, dynamic>);
        })
        .toList();
  }

  Future<void> add(String propertyId) async {
    await _dio.post(ApiConstants.favoriteById(propertyId));
  }

  Future<void> remove(String propertyId) async {
    await _dio.delete(ApiConstants.favoriteById(propertyId));
  }
}
