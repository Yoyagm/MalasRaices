import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../shared/response_helpers.dart';
import 'auth_service.dart';
import 'auth_validators.dart';

class AuthRouter {
  final AuthService _authService;

  AuthRouter({AuthService? authService})
      : _authService = authService ?? AuthService();

  Router get router {
    final r = Router();

    r.post('/register', _register);
    r.post('/login', _login);
    r.post('/refresh', _refresh);

    return r;
  }

  Future<Response> _register(Request request) async {
    final body = await readJsonBody(request);
    validateRegister(body);

    final result = await _authService.register(
      email: (body['email'] as String).trim().toLowerCase(),
      password: body['password'] as String,
      firstName: (body['firstName'] as String).trim(),
      lastName: (body['lastName'] as String).trim(),
      role: body['role'] as String,
    );

    return jsonResponse(result, statusCode: 201);
  }

  Future<Response> _login(Request request) async {
    final body = await readJsonBody(request);
    validateLogin(body);

    final result = await _authService.login(
      email: (body['email'] as String).trim().toLowerCase(),
      password: body['password'] as String,
    );

    return jsonResponse(result);
  }

  Future<Response> _refresh(Request request) async {
    final body = await readJsonBody(request);
    validateRefresh(body);

    final tokens = await _authService.refresh(body['refreshToken'] as String);

    return jsonResponse(tokens);
  }
}
