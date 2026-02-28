import 'dart:convert';

import 'package:shelf/shelf.dart';

/// Restricts access to specific roles. Must be used AFTER authMiddleware.
Middleware rolesMiddleware(List<String> allowedRoles) {
  return (Handler innerHandler) {
    return (Request request) async {
      final role = request.context['userRole'] as String?;

      if (role == null || !allowedRoles.contains(role)) {
        return Response(
          403,
          body: jsonEncode({
            'statusCode': 403,
            'message': 'No tienes permisos para esta acción',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      return innerHandler(request);
    };
  };
}
