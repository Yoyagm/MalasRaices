import 'package:dio/dio.dart';

import '../../../config/api/api_constants.dart';
import '../../../core/models/paginated_response.dart';
import '../../../core/models/property_model.dart';

class SearchRepository {
  final Dio _dio;

  SearchRepository({required Dio dio}) : _dio = dio;

  Future<PaginatedResponse<PropertyModel>> search({
    String? query,
    String? type,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int? bathrooms,
    double? lat,
    double? lng,
    double? radius,
    int page = 1,
    int limit = 20,
    String sort = 'newest',
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sort': sort,
    };

    if (query != null && query.isNotEmpty) params['q'] = query;
    if (type != null) params['type'] = type;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (bedrooms != null) params['bedrooms'] = bedrooms;
    if (bathrooms != null) params['bathrooms'] = bathrooms;
    if (lat != null) params['lat'] = lat;
    if (lng != null) params['lng'] = lng;
    if (radius != null) params['radius'] = radius;

    final response = await _dio.get(
      ApiConstants.search,
      queryParameters: params,
    );

    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      PropertyModel.fromJson,
    );
  }
}
