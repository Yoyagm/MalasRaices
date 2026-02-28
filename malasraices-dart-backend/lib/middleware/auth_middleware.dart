import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';

import '../config/database.dart';
import '../config/env.dart';
import '../shared/exceptions.dart';

/// Extracts and verifies JWT from Authorization header.
/// Sets 'userId', 'userEmail', 'userRole' in request context.
Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(
          401,
          body: jsonEncode({
            'statusCode': 401,
            'message': 'Token no proporcionado',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final token = authHeader.substring(7);

      try {
        final jwt = JWT.verify(token, SecretKey(env('JWT_SECRET')));
        final payload = jwt.payload as Map<String, dynamic>;
        final userId = payload['sub'] as String;

        // Verify user exists and is active
        final result = await dbPool.execute(
          Sql.named(
            'SELECT id, email, role, is_active FROM users WHERE id = @id',
          ),
          parameters: {'id': userId},
        );

        if (result.isEmpty) {
          return Response(
            401,
            body: jsonEncode({
              'statusCode': 401,
              'message': 'Usuario no encontrado',
              'timestamp': DateTime.now().toIso8601String(),
            }),
            headers: {'content-type': 'application/json'},
          );
        }

        final user = result.first.toColumnMap();
        if (user['is_active'] != true) {
          return Response(
            401,
            body: jsonEncode({
              'statusCode': 401,
              'message': 'Cuenta desactivada',
              'timestamp': DateTime.now().toIso8601String(),
            }),
            headers: {'content-type': 'application/json'},
          );
        }

        final updatedRequest = request.change(context: {
          'userId': userId,
          'userEmail': user['email'] as String,
          'userRole': user['role'] is UndecodedBytes
              ? (user['role'] as UndecodedBytes).asString
              : user['role'].toString(),
        });

        return innerHandler(updatedRequest);
      } on JWTExpiredException {
        return Response(
          401,
          body: jsonEncode({
            'statusCode': 401,
            'message': 'Token expirado',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'content-type': 'application/json'},
        );
      } on JWTException {
        return Response(
          401,
          body: jsonEncode({
            'statusCode': 401,
            'message': 'Token inválido',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    };
  };
}

/// Helper to get user data from request context.
String userId(Request request) => request.context['userId'] as String;
String userEmail(Request request) => request.context['userEmail'] as String;
String userRole(Request request) => request.context['userRole'] as String;

/// Validates JWT and returns enriched Request with user context.
/// Throws [ApiException] if auth fails.
Future<Request> authenticateRequest(Request request) async {
  final authHeader = request.headers['authorization'];
  if (authHeader == null || !authHeader.startsWith('Bearer ')) {
    throw const UnauthorizedException('Token no proporcionado');
  }

  final token = authHeader.substring(7);

  try {
    final jwt = JWT.verify(token, SecretKey(env('JWT_SECRET')));
    final payload = jwt.payload as Map<String, dynamic>;
    final uid = payload['sub'] as String;

    final result = await dbPool.execute(
      Sql.named('SELECT id, email, role, is_active FROM users WHERE id = @id'),
      parameters: {'id': uid},
    );

    if (result.isEmpty) throw const UnauthorizedException('Usuario no encontrado');

    final user = result.first.toColumnMap();
    if (user['is_active'] != true) {
      throw const UnauthorizedException('Cuenta desactivada');
    }

    return request.change(context: {
      'userId': uid,
      'userEmail': user['email'] as String,
      'userRole': user['role'] is UndecodedBytes
          ? (user['role'] as UndecodedBytes).asString
          : user['role'].toString(),
    });
  } on JWTExpiredException {
    throw const UnauthorizedException('Token expirado');
  } on JWTException {
    throw const UnauthorizedException('Token inválido');
  }
}

/// Validates JWT + OWNER role. Throws if not authorized.
Future<Request> authenticateOwner(Request request) async {
  final req = await authenticateRequest(request);
  final role = userRole(req);
  if (role != 'OWNER') {
    throw const ForbiddenException('No tienes permisos para esta acción');
  }
  return req;
}
