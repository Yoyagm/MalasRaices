import '../../shared/exceptions.dart';

final _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
final _passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])');

void validateRegister(Map<String, dynamic> body) {
  final errors = <String>[];

  final email = body['email'];
  if (email == null || email is! String || email.isEmpty) {
    errors.add('email es requerido');
  } else if (!_emailRegex.hasMatch(email)) {
    errors.add('email no es válido');
  }

  final password = body['password'];
  if (password == null || password is! String || password.isEmpty) {
    errors.add('password es requerido');
  } else {
    if (password.length < 8) {
      errors.add('password debe tener al menos 8 caracteres');
    }
    if (!_passwordRegex.hasMatch(password)) {
      errors.add(
        'password debe tener al menos una mayúscula, una minúscula, '
        'un número y un carácter especial (@\$!%*?&)',
      );
    }
  }

  final firstName = body['firstName'];
  if (firstName == null || firstName is! String || firstName.isEmpty) {
    errors.add('firstName es requerido');
  }

  final lastName = body['lastName'];
  if (lastName == null || lastName is! String || lastName.isEmpty) {
    errors.add('lastName es requerido');
  }

  final role = body['role'];
  if (role == null || role is! String || !['OWNER', 'TENANT'].contains(role)) {
    errors.add('role debe ser OWNER o TENANT');
  }

  if (errors.isNotEmpty) {
    throw BadRequestException(errors.join(', '));
  }
}

void validateLogin(Map<String, dynamic> body) {
  final errors = <String>[];

  if (body['email'] == null || (body['email'] as String).isEmpty) {
    errors.add('email es requerido');
  }
  if (body['password'] == null || (body['password'] as String).isEmpty) {
    errors.add('password es requerido');
  }

  if (errors.isNotEmpty) {
    throw BadRequestException(errors.join(', '));
  }
}

void validateRefresh(Map<String, dynamic> body) {
  if (body['refreshToken'] == null ||
      (body['refreshToken'] as String).isEmpty) {
    throw const BadRequestException('refreshToken es requerido');
  }
}
