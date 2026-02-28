import '../../shared/exceptions.dart';

const _validTypes = ['APARTMENT', 'HOUSE', 'STUDIO', 'ROOM', 'COMMERCIAL'];

void validateCreateProperty(Map<String, dynamic> body) {
  final errors = <String>[];

  if (body['title'] == null || (body['title'] as String).isEmpty) {
    errors.add('title es requerido');
  } else if ((body['title'] as String).length > 120) {
    errors.add('title no puede exceder 120 caracteres');
  }

  if (body['description'] == null || (body['description'] as String).isEmpty) {
    errors.add('description es requerido');
  } else if ((body['description'] as String).length > 2000) {
    errors.add('description no puede exceder 2000 caracteres');
  }

  if (body['price'] == null) {
    errors.add('price es requerido');
  } else {
    final price = (body['price'] is num)
        ? (body['price'] as num).toDouble()
        : double.tryParse(body['price'].toString());
    if (price == null || price < 0) {
      errors.add('price debe ser un número >= 0');
    }
  }

  if (body['address'] == null || (body['address'] as String).isEmpty) {
    errors.add('address es requerido');
  } else if ((body['address'] as String).length > 300) {
    errors.add('address no puede exceder 300 caracteres');
  }

  if (body['propertyType'] == null ||
      !_validTypes.contains(body['propertyType'])) {
    errors.add('propertyType debe ser: ${_validTypes.join(', ')}');
  }

  if (body['bedrooms'] == null) {
    errors.add('bedrooms es requerido');
  } else {
    final val = body['bedrooms'] is int
        ? body['bedrooms'] as int
        : int.tryParse(body['bedrooms'].toString());
    if (val == null || val < 0) errors.add('bedrooms debe ser >= 0');
  }

  if (body['bathrooms'] == null) {
    errors.add('bathrooms es requerido');
  } else {
    final val = body['bathrooms'] is int
        ? body['bathrooms'] as int
        : int.tryParse(body['bathrooms'].toString());
    if (val == null || val < 0) errors.add('bathrooms debe ser >= 0');
  }

  if (errors.isNotEmpty) {
    throw BadRequestException(errors.join(', '));
  }
}

void validateUpdateProperty(Map<String, dynamic> body) {
  final errors = <String>[];

  if (body.containsKey('title')) {
    if ((body['title'] as String).isEmpty) {
      errors.add('title no puede estar vacío');
    } else if ((body['title'] as String).length > 120) {
      errors.add('title no puede exceder 120 caracteres');
    }
  }

  if (body.containsKey('description') &&
      (body['description'] as String).length > 2000) {
    errors.add('description no puede exceder 2000 caracteres');
  }

  if (body.containsKey('propertyType') &&
      !_validTypes.contains(body['propertyType'])) {
    errors.add('propertyType debe ser: ${_validTypes.join(', ')}');
  }

  if (errors.isNotEmpty) {
    throw BadRequestException(errors.join(', '));
  }
}
