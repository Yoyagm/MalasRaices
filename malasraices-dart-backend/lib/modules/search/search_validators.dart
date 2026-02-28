import '../../shared/exceptions.dart';

const _validTypes = ['APARTMENT', 'HOUSE', 'STUDIO', 'ROOM', 'COMMERCIAL'];
const _validSorts = ['price_asc', 'price_desc', 'newest'];

Map<String, dynamic> parseSearchQuery(Uri uri) {
  final params = uri.queryParameters;
  final parsed = <String, dynamic>{};

  parsed['q'] = params['q'];
  parsed['page'] = int.tryParse(params['page'] ?? '') ?? 1;
  parsed['limit'] = int.tryParse(params['limit'] ?? '') ?? 20;

  if (parsed['page'] < 1) parsed['page'] = 1;
  if (parsed['limit'] < 1) parsed['limit'] = 1;
  if (parsed['limit'] > 50) parsed['limit'] = 50;

  if (params['type'] != null) {
    if (!_validTypes.contains(params['type'])) {
      throw BadRequestException(
        'type debe ser: ${_validTypes.join(', ')}',
      );
    }
    parsed['type'] = params['type'];
  }

  if (params['minPrice'] != null) {
    parsed['minPrice'] = double.tryParse(params['minPrice']!);
    if (parsed['minPrice'] == null || parsed['minPrice'] < 0) {
      throw const BadRequestException('minPrice debe ser >= 0');
    }
  }

  if (params['maxPrice'] != null) {
    parsed['maxPrice'] = double.tryParse(params['maxPrice']!);
    if (parsed['maxPrice'] == null || parsed['maxPrice'] < 0) {
      throw const BadRequestException('maxPrice debe ser >= 0');
    }
  }

  if (params['bedrooms'] != null) {
    parsed['bedrooms'] = int.tryParse(params['bedrooms']!);
  }
  if (params['bathrooms'] != null) {
    parsed['bathrooms'] = int.tryParse(params['bathrooms']!);
  }

  parsed['sort'] = params['sort'] ?? 'newest';
  if (!_validSorts.contains(parsed['sort'])) {
    parsed['sort'] = 'newest';
  }

  return parsed;
}
