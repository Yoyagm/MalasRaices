import 'package:postgres/postgres.dart';

import '../../config/database.dart';
import '../../shared/db_helpers.dart';

class SearchService {
  Future<Map<String, dynamic>> search(Map<String, dynamic> filters) async {
    final where = <String>["p.status = 'ACTIVE'"];
    final params = <String, Object?>{};

    // Keyword search
    if (filters['q'] != null && (filters['q'] as String).isNotEmpty) {
      where.add(
        '(p.title ILIKE @q OR p.description ILIKE @q OR p.address ILIKE @q)',
      );
      params['q'] = '%${filters['q']}%';
    }

    // Property type
    if (filters['type'] != null) {
      where.add('p.property_type = @type::"PropertyType"');
      params['type'] = filters['type'];
    }

    // Price range
    if (filters['minPrice'] != null) {
      where.add('p.price >= @minPrice');
      params['minPrice'] = filters['minPrice'].toString();
    }
    if (filters['maxPrice'] != null) {
      where.add('p.price <= @maxPrice');
      params['maxPrice'] = filters['maxPrice'].toString();
    }

    // Bedrooms / Bathrooms
    if (filters['bedrooms'] != null) {
      where.add('p.bedrooms >= @bedrooms');
      params['bedrooms'] = filters['bedrooms'] as int;
    }
    if (filters['bathrooms'] != null) {
      where.add('p.bathrooms >= @bathrooms');
      params['bathrooms'] = filters['bathrooms'] as int;
    }

    final whereClause = where.join(' AND ');

    // Sort
    String orderBy;
    switch (filters['sort']) {
      case 'price_asc':
        orderBy = 'p.price ASC';
      case 'price_desc':
        orderBy = 'p.price DESC';
      default:
        orderBy = 'p.created_at DESC';
    }

    final page = filters['page'] as int;
    final limit = filters['limit'] as int;
    final offset = (page - 1) * limit;

    // Count total
    final countResult = await dbPool.execute(
      Sql.named('SELECT COUNT(*) as total FROM properties p WHERE $whereClause'),
      parameters: params,
    );
    final total =
        countResult.first.toColumnMap()['total'] as int? ?? 0;

    // Fetch page
    final queryParams = Map<String, Object?>.from(params);
    queryParams['lim'] = limit;
    queryParams['off'] = offset;

    final result = await dbPool.execute(
      Sql.named('''
        SELECT p.*,
          u.first_name as owner_first_name,
          u.last_name as owner_last_name
        FROM properties p
        JOIN users u ON u.id = p.owner_id
        WHERE $whereClause
        ORDER BY $orderBy
        LIMIT @lim OFFSET @off
      '''),
      parameters: queryParams,
    );

    final properties = <Map<String, dynamic>>[];
    for (final row in result) {
      final map = row.toColumnMap();
      final prop = rowToJson(map);

      // Extract owner into nested object
      prop['owner'] = {
        'firstName': map['owner_first_name'],
        'lastName': map['owner_last_name'],
      };
      prop.remove('ownerFirstName');
      prop.remove('ownerLastName');

      // Get cover image only
      final images = await _getCoverImage(prop['id'] as String);
      prop['images'] = images;

      properties.add(prop);
    }

    return {
      'data': properties,
      'page': page,
      'limit': limit,
      'total': total,
    };
  }

  Future<List<Map<String, dynamic>>> _getCoverImage(String propertyId) async {
    final result = await dbPool.execute(
      Sql.named('''
        SELECT id, image_url, display_order, is_cover, created_at
        FROM property_images
        WHERE property_id = @propertyId AND is_cover = true
        ORDER BY display_order ASC
        LIMIT 1
      '''),
      parameters: {'propertyId': propertyId},
    );

    if (result.isEmpty) {
      // Fallback: first image
      final fallback = await dbPool.execute(
        Sql.named('''
          SELECT id, image_url, display_order, is_cover, created_at
          FROM property_images
          WHERE property_id = @propertyId
          ORDER BY display_order ASC
          LIMIT 1
        '''),
        parameters: {'propertyId': propertyId},
      );
      return fallback.map((r) => rowToJson(r.toColumnMap())).toList();
    }

    return result.map((r) => rowToJson(r.toColumnMap())).toList();
  }
}
