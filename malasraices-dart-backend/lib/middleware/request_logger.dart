import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

final _log = Logger('HTTP');

Middleware requestLogger() {
  return (Handler innerHandler) {
    return (Request request) async {
      final stopwatch = Stopwatch()..start();
      final response = await innerHandler(request);
      stopwatch.stop();

      _log.info(
        '${request.method} ${request.requestedUri.path} '
        '→ ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)',
      );

      return response;
    };
  };
}
