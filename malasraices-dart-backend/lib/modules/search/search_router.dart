import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../shared/response_helpers.dart';
import 'search_service.dart';
import 'search_validators.dart';

class SearchRouter {
  final SearchService _searchService;

  SearchRouter({SearchService? searchService})
      : _searchService = searchService ?? SearchService();

  Router get router {
    final r = Router();

    r.get('/', _search);

    return r;
  }

  Future<Response> _search(Request request) async {
    final filters = parseSearchQuery(request.requestedUri);
    final result = await _searchService.search(filters);

    return paginatedResponse(
      data: (result['data'] as List).cast<Map<String, dynamic>>(),
      page: result['page'] as int,
      limit: result['limit'] as int,
      total: result['total'] as int,
    );
  }
}
