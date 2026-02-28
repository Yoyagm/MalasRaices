class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    this.message = 'Error del servidor',
    this.statusCode,
  });
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException([this.message = 'No autorizado']);
}
