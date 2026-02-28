import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../middleware/auth_middleware.dart';
import '../../shared/response_helpers.dart';
import 'properties_service.dart';
import 'properties_validators.dart';

class PropertiesRouter {
  final PropertiesService _propertiesService;

  PropertiesRouter({PropertiesService? propertiesService})
      : _propertiesService = propertiesService ?? PropertiesService();

  Router get router {
    final r = Router();

    r.post('/', _create);
    r.get('/', _getMyProperties);
    r.get('/<id>', _getById);
    r.patch('/<id>', _update);
    r.delete('/<id>', _deactivate);

    return r;
  }

  Future<Response> _create(Request request) async {
    final body = await readJsonBody(request);
    validateCreateProperty(body);

    final ownerId = userId(request);
    final property = await _propertiesService.create(ownerId, body);

    return jsonResponse(property, statusCode: 201);
  }

  Future<Response> _getMyProperties(Request request) async {
    final ownerId = userId(request);
    final properties = await _propertiesService.getByOwner(ownerId);
    return jsonResponse(properties);
  }

  Future<Response> _getById(Request request, String id) async {
    final property = await _propertiesService.getById(id);
    return jsonResponse(property);
  }

  Future<Response> _update(Request request, String id) async {
    final body = await readJsonBody(request);
    validateUpdateProperty(body);

    final ownerId = userId(request);
    final property = await _propertiesService.update(id, ownerId, body);
    return jsonResponse(property);
  }

  Future<Response> _deactivate(Request request, String id) async {
    final ownerId = userId(request);
    final property = await _propertiesService.deactivate(id, ownerId);
    return jsonResponse(property);
  }
}
