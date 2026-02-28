class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class BadRequestException extends ApiException {
  const BadRequestException(String message) : super(400, message);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([String message = 'No autorizado'])
      : super(401, message);
}

class ForbiddenException extends ApiException {
  const ForbiddenException([String message = 'Acceso denegado'])
      : super(403, message);
}

class NotFoundException extends ApiException {
  const NotFoundException([String message = 'Recurso no encontrado'])
      : super(404, message);
}

class ConflictException extends ApiException {
  const ConflictException(String message) : super(409, message);
}
