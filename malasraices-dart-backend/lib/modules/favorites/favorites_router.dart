import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../middleware/auth_middleware.dart';
import '../../shared/response_helpers.dart';
import 'favorites_service.dart';

class FavoritesRouter {
  final FavoritesService _favoritesService;

  FavoritesRouter({FavoritesService? favoritesService})
      : _favoritesService = favoritesService ?? FavoritesService();

  Router get router {
    final r = Router();

    r.post('/<propertyId>', _add);
    r.delete('/<propertyId>', _remove);
    r.get('/', _getAll);

    return r;
  }

  Future<Response> _add(Request request, String propertyId) async {
    final uid = userId(request);
    final result = await _favoritesService.add(uid, propertyId);
    return jsonResponse(result, statusCode: 201);
  }

  Future<Response> _remove(Request request, String propertyId) async {
    final uid = userId(request);
    await _favoritesService.remove(uid, propertyId);
    return jsonResponse({'message': 'Eliminado de favoritos'});
  }

  Future<Response> _getAll(Request request) async {
    final uid = userId(request);
    final favorites = await _favoritesService.getAll(uid);
    return jsonResponse(favorites);
  }
}
