import '../../shared/exceptions.dart';

final _urlRegex = RegExp(r'^https?://');

void validateUpdateProfile(Map<String, dynamic> body) {
  final errors = <String>[];

  if (body.containsKey('firstName')) {
    if (body['firstName'] is! String || (body['firstName'] as String).isEmpty) {
      errors.add('firstName no puede estar vacío');
    }
  }

  if (body.containsKey('lastName')) {
    if (body['lastName'] is! String || (body['lastName'] as String).isEmpty) {
      errors.add('lastName no puede estar vacío');
    }
  }

  if (body.containsKey('profileImageUrl') &&
      body['profileImageUrl'] != null) {
    final url = body['profileImageUrl'] as String;
    if (url.isNotEmpty && !_urlRegex.hasMatch(url)) {
      errors.add('profileImageUrl debe ser una URL válida');
    }
  }

  if (errors.isNotEmpty) {
    throw BadRequestException(errors.join(', '));
  }
}
