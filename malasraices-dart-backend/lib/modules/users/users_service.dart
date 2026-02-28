import 'package:postgres/postgres.dart';

import '../../config/database.dart';
import '../../shared/db_helpers.dart';
import '../../shared/exceptions.dart';

class UsersService {
  Future<Map<String, dynamic>> getProfile(String userId) async {
    final result = await dbPool.execute(
      Sql.named('''
        SELECT id, email, role, first_name, last_name, phone,
               profile_image_url, email_verified, created_at
        FROM users WHERE id = @id
      '''),
      parameters: {'id': userId},
    );

    if (result.isEmpty) {
      throw const NotFoundException('Usuario no encontrado');
    }

    return rowToJson(result.first.toColumnMap());
  }

  Future<Map<String, dynamic>> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final setClauses = <String>[];
    final params = <String, Object?>{'id': userId};

    if (data.containsKey('firstName')) {
      setClauses.add('first_name = @firstName');
      params['firstName'] = data['firstName'];
    }
    if (data.containsKey('lastName')) {
      setClauses.add('last_name = @lastName');
      params['lastName'] = data['lastName'];
    }
    if (data.containsKey('phone')) {
      setClauses.add('phone = @phone');
      params['phone'] = data['phone'];
    }
    if (data.containsKey('profileImageUrl')) {
      setClauses.add('profile_image_url = @profileImageUrl');
      params['profileImageUrl'] = data['profileImageUrl'];
    }

    if (setClauses.isEmpty) {
      return getProfile(userId);
    }

    setClauses.add('updated_at = NOW()');

    await dbPool.execute(
      Sql.named(
        'UPDATE users SET ${setClauses.join(', ')} WHERE id = @id',
      ),
      parameters: params,
    );

    return getProfile(userId);
  }
}
