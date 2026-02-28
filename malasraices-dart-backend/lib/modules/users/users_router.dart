import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../middleware/auth_middleware.dart';
import '../../shared/response_helpers.dart';
import 'users_service.dart';
import 'users_validators.dart';

class UsersRouter {
  final UsersService _usersService;

  UsersRouter({UsersService? usersService})
      : _usersService = usersService ?? UsersService();

  Router get router {
    final r = Router();

    r.get('/me', _getProfile);
    r.patch('/me', _updateProfile);

    return r;
  }

  Future<Response> _getProfile(Request request) async {
    final id = userId(request);
    final profile = await _usersService.getProfile(id);
    return jsonResponse(profile);
  }

  Future<Response> _updateProfile(Request request) async {
    final id = userId(request);
    final body = await readJsonBody(request);
    validateUpdateProfile(body);

    final profile = await _usersService.updateProfile(id, body);
    return jsonResponse(profile);
  }
}
