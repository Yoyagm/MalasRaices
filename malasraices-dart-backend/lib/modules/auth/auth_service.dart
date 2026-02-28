import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

import '../../config/database.dart';
import '../../config/env.dart';
import '../../shared/db_helpers.dart';
import '../../shared/exceptions.dart';

String _decodeField(dynamic value) =>
    value is UndecodedBytes ? value.asString : value.toString();

const _uuid = Uuid();

class AuthService {
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    // Check if email exists
    final existing = await dbPool.execute(
      Sql.named('SELECT id FROM users WHERE email = @email'),
      parameters: {'email': email},
    );
    if (existing.isNotEmpty) {
      throw const ConflictException('El email ya está registrado');
    }

    final id = _uuid.v4();
    final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 12));

    await dbPool.execute(
      Sql.named('''
        INSERT INTO users (id, email, password_hash, first_name, last_name, role, created_at, updated_at)
        VALUES (@id, @email, @hash, @firstName, @lastName, @role::"UserRole", NOW(), NOW())
      '''),
      parameters: {
        'id': id,
        'email': email,
        'hash': passwordHash,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
      },
    );

    final userResult = await dbPool.execute(
      Sql.named('SELECT * FROM users WHERE id = @id'),
      parameters: {'id': id},
    );
    final user = userToJson(userResult.first.toColumnMap());

    final tokens = _generateTokens(id, email, role);

    return {
      'user': user,
      'accessToken': tokens['accessToken'],
      'refreshToken': tokens['refreshToken'],
    };
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await dbPool.execute(
      Sql.named('SELECT * FROM users WHERE email = @email'),
      parameters: {'email': email},
    );

    if (result.isEmpty) {
      throw const UnauthorizedException('Credenciales inválidas');
    }

    final row = result.first.toColumnMap();
    final passwordHash = row['password_hash'] as String;
    final isActive = row['is_active'] as bool;

    if (!isActive) {
      throw const UnauthorizedException('Cuenta desactivada');
    }

    if (!BCrypt.checkpw(password, passwordHash)) {
      throw const UnauthorizedException('Credenciales inválidas');
    }

    final user = userToJson(row);
    final id = row['id'] as String;
    final role = _decodeField(row['role']);

    final tokens = _generateTokens(id, email, role);

    return {
      'user': user,
      'accessToken': tokens['accessToken'],
      'refreshToken': tokens['refreshToken'],
    };
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    try {
      final jwt = JWT.verify(
        refreshToken,
        SecretKey(env('JWT_REFRESH_SECRET')),
      );
      final payload = jwt.payload as Map<String, dynamic>;
      final userId = payload['sub'] as String;

      final result = await dbPool.execute(
        Sql.named('SELECT id, email, role, is_active FROM users WHERE id = @id'),
        parameters: {'id': userId},
      );

      if (result.isEmpty) {
        throw const UnauthorizedException('Usuario no encontrado');
      }

      final row = result.first.toColumnMap();
      if (row['is_active'] != true) {
        throw const UnauthorizedException('Cuenta desactivada');
      }

      final email = row['email'] as String;
      final role = _decodeField(row['role']);

      return _generateTokens(userId, email, role);
    } on JWTExpiredException {
      throw const UnauthorizedException('Refresh token expirado');
    } on JWTException {
      throw const UnauthorizedException('Refresh token inválido');
    }
  }

  Map<String, String> _generateTokens(
    String userId,
    String email,
    String role,
  ) {
    final accessToken = JWT({
      'sub': userId,
      'email': email,
      'role': role,
    }).sign(
      SecretKey(env('JWT_SECRET')),
      expiresIn: const Duration(minutes: 15),
    );

    final refreshToken = JWT({
      'sub': userId,
      'email': email,
      'role': role,
    }).sign(
      SecretKey(env('JWT_REFRESH_SECRET')),
      expiresIn: const Duration(days: 7),
    );

    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
