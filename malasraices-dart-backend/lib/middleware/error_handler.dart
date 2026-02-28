import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

import '../shared/exceptions.dart';

final _log = Logger('ErrorHandler');

Middleware errorHandler() {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        return await innerHandler(request);
      } on ApiException catch (e) {
        return Response(
          e.statusCode,
          body: jsonEncode({
            'statusCode': e.statusCode,
            'message': e.message,
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'content-type': 'application/json'},
        );
      } on FormatException catch (e) {
        return Response(
          400,
          body: jsonEncode({
            'statusCode': 400,
            'message': 'JSON inválido: ${e.message}',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'content-type': 'application/json'},
        );
      } catch (e, st) {
        _log.severe('Unhandled error', e, st);
        return Response(
          500,
          body: jsonEncode({
            'statusCode': 500,
            'message': 'Error interno del servidor',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    };
  };
}
