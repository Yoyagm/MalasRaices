import 'package:postgres/postgres.dart';

/// Converts a snake_case database column map to camelCase keys.
Map<String, dynamic> snakeToCamel(Map<String, dynamic> row) {
  return row.map((key, value) => MapEntry(_toCamelCase(key), value));
}

String _toCamelCase(String snake) {
  final parts = snake.split('_');
  if (parts.length == 1) return parts[0];
  return parts[0] +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

/// Converts DB types (UndecodedBytes, DateTime, etc.) to JSON-safe types.
dynamic toJsonSafe(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value.toIso8601String();
  if (value is UndecodedBytes) return value.asString;
  return value;
}

/// Converts a full row map to JSON-safe camelCase map.
Map<String, dynamic> rowToJson(Map<String, dynamic> row) {
  final camel = snakeToCamel(row);
  return camel.map((key, value) => MapEntry(key, toJsonSafe(value)));
}

/// Builds a user JSON excluding sensitive fields.
Map<String, dynamic> userToJson(Map<String, dynamic> row) {
  final json = rowToJson(row);
  json.remove('passwordHash');
  return json;
}
