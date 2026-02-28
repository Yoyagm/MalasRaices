import 'dart:io';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:malasraices_dart_backend/config/database.dart';
import 'package:malasraices_dart_backend/config/env.dart';
import 'package:malasraices_dart_backend/middleware/auth_middleware.dart';
import 'package:malasraices_dart_backend/middleware/error_handler.dart';
import 'package:malasraices_dart_backend/middleware/request_logger.dart';
import 'package:malasraices_dart_backend/middleware/roles_middleware.dart';
import 'package:malasraices_dart_backend/modules/auth/auth_router.dart';
import 'package:malasraices_dart_backend/modules/favorites/favorites_service.dart';
import 'package:malasraices_dart_backend/modules/properties/properties_service.dart';
import 'package:malasraices_dart_backend/modules/properties/properties_validators.dart';
import 'package:malasraices_dart_backend/modules/search/search_service.dart';
import 'package:malasraices_dart_backend/modules/search/search_validators.dart';
import 'package:malasraices_dart_backend/modules/users/users_service.dart';
import 'package:malasraices_dart_backend/modules/users/users_validators.dart';
import 'package:malasraices_dart_backend/shared/exceptions.dart';
import 'package:malasraices_dart_backend/shared/response_helpers.dart';

void main() async {
  // Setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    stderr.writeln(
      '${record.time} [${record.level.name}] ${record.loggerName}: ${record.message}',
    );
    if (record.error != null) stderr.writeln('  ${record.error}');
  });

  final log = Logger('Server');

  // Load environment
  loadEnv();

  // Connect to database
  log.info('Connecting to database...');
  await initDatabase();
  log.info('Database connected');

  // Services
  final usersService = UsersService();
  final propertiesService = PropertiesService();
  final searchService = SearchService();
  final favoritesService = FavoritesService();

  // Auth sub-router (only module that uses mount — 3 POST routes)
  final authRouter = AuthRouter();

  // Middleware helpers
  Handler withAuth(Future<Response> Function(Request) handler) {
    return const Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler(handler);
  }

  Handler withOwner(Future<Response> Function(Request) handler) {
    return const Pipeline()
        .addMiddleware(authMiddleware())
        .addMiddleware(rolesMiddleware(['OWNER']))
        .addHandler(handler);
  }

  // ── Main router ───────────────────────────────────────
  final app = Router();

  // ── Auth (public, uses mount for /register, /login, /refresh) ──
  app.mount('/api/auth/', authRouter.router.call);

  // ── Search (public) ───────────────────────────────────
  app.get('/api/search', (Request request) async {
    final filters = parseSearchQuery(request.requestedUri);
    final result = await searchService.search(filters);
    return paginatedResponse(
      data: (result['data'] as List).cast<Map<String, dynamic>>(),
      page: result['page'] as int,
      limit: result['limit'] as int,
      total: result['total'] as int,
    );
  });

  // ── Property detail (public) ──────────────────────────
  app.get('/api/properties/<id>', (Request request, String id) async {
    final property = await propertiesService.getById(id);
    return jsonResponse(property);
  });

  // ── Users (authenticated) ─────────────────────────────
  app.get('/api/users/me', withAuth((Request request) async {
    final id = userId(request);
    final profile = await usersService.getProfile(id);
    return jsonResponse(profile);
  }));

  app.patch('/api/users/me', withAuth((Request request) async {
    final id = userId(request);
    final body = await readJsonBody(request);
    validateUpdateProfile(body);
    final profile = await usersService.updateProfile(id, body);
    return jsonResponse(profile);
  }));

  app.patch('/api/users/<id>', (Request request, String id) async {
    final req = await authenticateRequest(request);
    final requesterId = userId(req);
    final role = userRole(req);
    if (requesterId != id && role != 'ADMIN') {
      throw const ForbiddenException('No tienes permisos para editar este usuario');
    }
    final body = await readJsonBody(req);
    validateUpdateProfile(body);
    final profile = await usersService.updateProfile(id, body);
    return jsonResponse(profile);
  });

  // ── Favorites (authenticated) ─────────────────────────
  app.get('/api/favorites', withAuth((Request request) async {
    final uid = userId(request);
    final favorites = await favoritesService.getAll(uid);
    return jsonResponse(favorites);
  }));

  app.post('/api/favorites/<propertyId>', (Request request, String propertyId) async {
    final req = await authenticateRequest(request);
    final uid = userId(req);
    final result = await favoritesService.add(uid, propertyId);
    return jsonResponse(result, statusCode: 201);
  });

  app.delete('/api/favorites/<propertyId>', (Request request, String propertyId) async {
    final req = await authenticateRequest(request);
    final uid = userId(req);
    await favoritesService.remove(uid, propertyId);
    return jsonResponse({'message': 'Eliminado de favoritos'});
  });

  // ── Properties CRUD (owner only) ─────────────────────
  app.post('/api/properties', withOwner((Request request) async {
    final body = await readJsonBody(request);
    validateCreateProperty(body);
    final ownerId = userId(request);
    final property = await propertiesService.create(ownerId, body);
    return jsonResponse(property, statusCode: 201);
  }));

  app.get('/api/properties', withOwner((Request request) async {
    final ownerId = userId(request);
    final properties = await propertiesService.getByOwner(ownerId);
    return jsonResponse(properties);
  }));

  app.patch('/api/properties/<id>', (Request request, String id) async {
    final req = await authenticateOwner(request);
    final body = await readJsonBody(req);
    validateUpdateProperty(body);
    final ownerId = userId(req);
    final property = await propertiesService.update(id, ownerId, body);
    return jsonResponse(property);
  });

  app.delete('/api/properties/<id>', (Request request, String id) async {
    final req = await authenticateOwner(request);
    final ownerId = userId(req);
    final property = await propertiesService.deactivate(id, ownerId);
    return jsonResponse(property);
  });

  // ── CORS configuration ────────────────────────────────
  final allowedOrigins = env('ALLOWED_ORIGINS', 'http://localhost:3000');
  final corsConfig = {
    ACCESS_CONTROL_ALLOW_ORIGIN: allowedOrigins.split(',').first,
    ACCESS_CONTROL_ALLOW_METHODS: 'GET, POST, PATCH, DELETE, OPTIONS',
    ACCESS_CONTROL_ALLOW_HEADERS: 'Origin, Content-Type, Authorization',
    ACCESS_CONTROL_ALLOW_CREDENTIALS: 'true',
  };

  // ── Global pipeline ───────────────────────────────────
  final handler = const Pipeline()
      .addMiddleware(corsHeaders(headers: corsConfig))
      .addMiddleware(errorHandler())
      .addMiddleware(requestLogger())
      .addHandler(app.call);

  // ── Start server ──────────────────────────────────────
  final port = envInt('PORT', 3000);
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);

  log.info('Server running on http://localhost:${server.port}');
  log.info('Press Ctrl+C to stop');

  // Graceful shutdown
  ProcessSignal.sigint.watch().listen((_) async {
    log.info('Shutting down...');
    await server.close();
    await closeDatabase();
    exit(0);
  });
}
