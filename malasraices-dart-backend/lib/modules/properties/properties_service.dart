import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

import '../../config/database.dart';
import '../../shared/db_helpers.dart';
import '../../shared/exceptions.dart';

const _uuid = Uuid();

class PropertiesService {
  Future<Map<String, dynamic>> create(
    String ownerId,
    Map<String, dynamic> data,
  ) async {
    final id = _uuid.v4();

    await dbPool.execute(
      Sql.named('''
        INSERT INTO properties (
          id, owner_id, title, description, price, address,
          latitude, longitude, property_type, bedrooms, bathrooms,
          area_sqm, status, created_at, updated_at
        ) VALUES (
          @id, @ownerId, @title, @description, @price, @address,
          @latitude, @longitude, @propertyType::"PropertyType",
          @bedrooms, @bathrooms, @areaSqm, 'ACTIVE'::"PropertyStatus",
          NOW(), NOW()
        )
      '''),
      parameters: {
        'id': id,
        'ownerId': ownerId,
        'title': data['title'],
        'description': data['description'],
        'price': data['price'].toString(),
        'address': data['address'],
        'latitude': data['latitude']?.toString(),
        'longitude': data['longitude']?.toString(),
        'propertyType': data['propertyType'],
        'bedrooms': data['bedrooms'] is int
            ? data['bedrooms']
            : int.parse(data['bedrooms'].toString()),
        'bathrooms': data['bathrooms'] is int
            ? data['bathrooms']
            : int.parse(data['bathrooms'].toString()),
        'areaSqm': data['areaSqm']?.toString(),
      },
    );

    return getById(id);
  }

  Future<List<Map<String, dynamic>>> getByOwner(String ownerId) async {
    final result = await dbPool.execute(
      Sql.named('''
        SELECT p.*,
          (SELECT COUNT(*) FROM favorites f WHERE f.property_id = p.id) as favorite_count
        FROM properties p
        WHERE p.owner_id = @ownerId
        ORDER BY p.created_at DESC
      '''),
      parameters: {'ownerId': ownerId},
    );

    final properties = <Map<String, dynamic>>[];
    for (final row in result) {
      final prop = rowToJson(row.toColumnMap());
      prop['images'] = await _getImages(prop['id'] as String);
      properties.add(prop);
    }

    return properties;
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final result = await dbPool.execute(
      Sql.named('SELECT * FROM properties WHERE id = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) {
      throw const NotFoundException('Propiedad no encontrada');
    }

    final prop = rowToJson(result.first.toColumnMap());

    // Get images
    prop['images'] = await _getImages(id);

    // Get owner info
    final ownerResult = await dbPool.execute(
      Sql.named('''
        SELECT first_name, last_name, phone, email
        FROM users WHERE id = @id
      '''),
      parameters: {'id': prop['ownerId']},
    );

    if (ownerResult.isNotEmpty) {
      final owner = ownerResult.first.toColumnMap();
      prop['owner'] = {
        'firstName': owner['first_name'],
        'lastName': owner['last_name'],
        'phone': owner['phone'],
        'email': owner['email'],
      };
    }

    return prop;
  }

  Future<Map<String, dynamic>> update(
    String id,
    String ownerId,
    Map<String, dynamic> data,
  ) async {
    // Verify ownership
    final existing = await dbPool.execute(
      Sql.named('SELECT owner_id FROM properties WHERE id = @id'),
      parameters: {'id': id},
    );

    if (existing.isEmpty) {
      throw const NotFoundException('Propiedad no encontrada');
    }

    if (existing.first.toColumnMap()['owner_id'] != ownerId) {
      throw const ForbiddenException(
        'No tienes permisos para editar esta propiedad',
      );
    }

    final setClauses = <String>[];
    final params = <String, Object?>{'id': id};

    final fieldMap = {
      'title': 'title',
      'description': 'description',
      'address': 'address',
    };

    for (final entry in fieldMap.entries) {
      if (data.containsKey(entry.key)) {
        setClauses.add('${_toSnake(entry.key)} = @${entry.key}');
        params[entry.key] = data[entry.key];
      }
    }

    if (data.containsKey('price')) {
      setClauses.add('price = @price');
      params['price'] = data['price'].toString();
    }
    if (data.containsKey('latitude')) {
      setClauses.add('latitude = @latitude');
      params['latitude'] = data['latitude']?.toString();
    }
    if (data.containsKey('longitude')) {
      setClauses.add('longitude = @longitude');
      params['longitude'] = data['longitude']?.toString();
    }
    if (data.containsKey('propertyType')) {
      setClauses.add('property_type = @propertyType::"PropertyType"');
      params['propertyType'] = data['propertyType'];
    }
    if (data.containsKey('bedrooms')) {
      setClauses.add('bedrooms = @bedrooms');
      params['bedrooms'] = data['bedrooms'] is int
          ? data['bedrooms']
          : int.parse(data['bedrooms'].toString());
    }
    if (data.containsKey('bathrooms')) {
      setClauses.add('bathrooms = @bathrooms');
      params['bathrooms'] = data['bathrooms'] is int
          ? data['bathrooms']
          : int.parse(data['bathrooms'].toString());
    }
    if (data.containsKey('areaSqm')) {
      setClauses.add('area_sqm = @areaSqm');
      params['areaSqm'] = data['areaSqm']?.toString();
    }

    if (setClauses.isEmpty) {
      return getById(id);
    }

    setClauses.add('updated_at = NOW()');

    await dbPool.execute(
      Sql.named(
        'UPDATE properties SET ${setClauses.join(', ')} WHERE id = @id',
      ),
      parameters: params,
    );

    return getById(id);
  }

  Future<Map<String, dynamic>> deactivate(String id, String ownerId) async {
    final existing = await dbPool.execute(
      Sql.named('SELECT owner_id FROM properties WHERE id = @id'),
      parameters: {'id': id},
    );

    if (existing.isEmpty) {
      throw const NotFoundException('Propiedad no encontrada');
    }

    if (existing.first.toColumnMap()['owner_id'] != ownerId) {
      throw const ForbiddenException(
        'No tienes permisos para desactivar esta propiedad',
      );
    }

    await dbPool.execute(
      Sql.named('''
        UPDATE properties
        SET status = 'INACTIVE'::"PropertyStatus", updated_at = NOW()
        WHERE id = @id
      '''),
      parameters: {'id': id},
    );

    return getById(id);
  }

  Future<List<Map<String, dynamic>>> _getImages(String propertyId) async {
    final result = await dbPool.execute(
      Sql.named('''
        SELECT id, image_url, public_id, display_order, is_cover, created_at
        FROM property_images
        WHERE property_id = @propertyId
        ORDER BY display_order ASC
      '''),
      parameters: {'propertyId': propertyId},
    );

    return result.map((r) => rowToJson(r.toColumnMap())).toList();
  }

  String _toSnake(String camel) {
    return camel.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (m) => '_${m.group(0)!.toLowerCase()}',
    );
  }
}
