import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

import '../../config/database.dart';
import '../../shared/db_helpers.dart';
import '../../shared/exceptions.dart';

const _uuid = Uuid();

class FavoritesService {
  Future<Map<String, dynamic>> add(String userId, String propertyId) async {
    // Verify property exists
    final propResult = await dbPool.execute(
      Sql.named('SELECT id, title, price FROM properties WHERE id = @id'),
      parameters: {'id': propertyId},
    );
    if (propResult.isEmpty) {
      throw const NotFoundException('Propiedad no encontrada');
    }

    // Check if already favorited
    final existing = await dbPool.execute(
      Sql.named('''
        SELECT id FROM favorites
        WHERE user_id = @userId AND property_id = @propertyId
      '''),
      parameters: {'userId': userId, 'propertyId': propertyId},
    );
    if (existing.isNotEmpty) {
      throw const ConflictException('La propiedad ya está en favoritos');
    }

    final id = _uuid.v4();
    await dbPool.execute(
      Sql.named('''
        INSERT INTO favorites (id, user_id, property_id, created_at)
        VALUES (@id, @userId, @propertyId, NOW())
      '''),
      parameters: {'id': id, 'userId': userId, 'propertyId': propertyId},
    );

    final propMap = propResult.first.toColumnMap();
    return {
      'id': id,
      'userId': userId,
      'propertyId': propertyId,
      'createdAt': DateTime.now().toIso8601String(),
      'property': {
        'id': propMap['id'],
        'title': propMap['title'],
        'price': propMap['price']?.toString(),
      },
    };
  }

  Future<void> remove(String userId, String propertyId) async {
    final result = await dbPool.execute(
      Sql.named('''
        DELETE FROM favorites
        WHERE user_id = @userId AND property_id = @propertyId
      '''),
      parameters: {'userId': userId, 'propertyId': propertyId},
    );

    if (result.affectedRows == 0) {
      throw const NotFoundException('Favorito no encontrado');
    }
  }

  Future<List<Map<String, dynamic>>> getAll(String userId) async {
    final result = await dbPool.execute(
      Sql.named('''
        SELECT f.id, f.user_id, f.property_id, f.created_at,
          p.id as p_id, p.owner_id, p.title, p.description, p.price,
          p.address, p.latitude, p.longitude, p.property_type,
          p.bedrooms, p.bathrooms, p.area_sqm, p.status,
          p.created_at as p_created_at, p.updated_at as p_updated_at,
          u.first_name as owner_first_name,
          u.last_name as owner_last_name
        FROM favorites f
        JOIN properties p ON p.id = f.property_id
        JOIN users u ON u.id = p.owner_id
        WHERE f.user_id = @userId
        ORDER BY f.created_at DESC
      '''),
      parameters: {'userId': userId},
    );

    final favorites = <Map<String, dynamic>>[];
    for (final row in result) {
      final map = row.toColumnMap();

      // Get cover image
      final imgResult = await dbPool.execute(
        Sql.named('''
          SELECT id, image_url, display_order, is_cover, created_at
          FROM property_images
          WHERE property_id = @propertyId
          ORDER BY (is_cover = true) DESC, display_order ASC
          LIMIT 1
        '''),
        parameters: {'propertyId': map['property_id']},
      );
      final images =
          imgResult.map((r) => rowToJson(r.toColumnMap())).toList();

      favorites.add({
        'id': map['id'],
        'userId': map['user_id'],
        'propertyId': map['property_id'],
        'createdAt': toJsonSafe(map['created_at']),
        'property': {
          'id': map['p_id'],
          'ownerId': map['owner_id'],
          'title': map['title'],
          'description': map['description'],
          'price': map['price']?.toString(),
          'address': map['address'],
          'latitude': map['latitude']?.toString(),
          'longitude': map['longitude']?.toString(),
          'propertyType': map['property_type'] is UndecodedBytes ? (map['property_type'] as UndecodedBytes).asString : map['property_type'].toString(),
          'bedrooms': map['bedrooms'],
          'bathrooms': map['bathrooms'],
          'areaSqm': map['area_sqm']?.toString(),
          'status': map['status'] is UndecodedBytes ? (map['status'] as UndecodedBytes).asString : map['status'].toString(),
          'createdAt': toJsonSafe(map['p_created_at']),
          'updatedAt': toJsonSafe(map['p_updated_at']),
          'images': images,
          'owner': {
            'firstName': map['owner_first_name'],
            'lastName': map['owner_last_name'],
          },
        },
      });
    }

    return favorites;
  }
}
