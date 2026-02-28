import 'package:postgres/postgres.dart';

import 'env.dart';

late Pool dbPool;

Future<void> initDatabase() async {
  final databaseUrl = env('DATABASE_URL');

  final endpoint = _parseConnectionString(databaseUrl);

  dbPool = Pool.withEndpoints(
    [endpoint],
    settings: PoolSettings(
      maxConnectionCount: 5,
      sslMode: SslMode.require,
    ),
  );

  // Verify connection
  await dbPool.execute('SELECT 1');
}

Endpoint _parseConnectionString(String url) {
  final uri = Uri.parse(url);
  return Endpoint(
    host: uri.host,
    port: uri.port != 0 ? uri.port : 5432,
    database: uri.pathSegments.isNotEmpty ? uri.pathSegments.first : 'neondb',
    username: uri.userInfo.split(':').first,
    password: uri.userInfo.contains(':') ? uri.userInfo.split(':').last : null,
  );
}

Future<void> closeDatabase() async {
  await dbPool.close();
}
