import 'dart:convert';

import 'package:shelf/shelf.dart';

Response jsonResponse(
  Object? body, {
  int statusCode = 200,
  Map<String, String>? headers,
}) {
  return Response(
    statusCode,
    body: jsonEncode(body),
    headers: {
      'content-type': 'application/json',
      ...?headers,
    },
  );
}

Response paginatedResponse({
  required List<Map<String, dynamic>> data,
  required int page,
  required int limit,
  required int total,
}) {
  final totalPages = (total / limit).ceil();
  return jsonResponse({
    'data': data,
    'meta': {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
      'hasNext': page < totalPages,
      'hasPrev': page > 1,
    },
  });
}

Future<Map<String, dynamic>> readJsonBody(Request request) async {
  final body = await request.readAsString();
  if (body.isEmpty) return {};
  return jsonDecode(body) as Map<String, dynamic>;
}
