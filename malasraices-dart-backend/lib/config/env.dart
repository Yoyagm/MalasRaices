import 'package:dotenv/dotenv.dart';

late final DotEnv _env;

void loadEnv() {
  _env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
}

String env(String key, [String fallback = '']) {
  return _env.getOrElse(key, () => fallback);
}

int envInt(String key, [int fallback = 0]) {
  return int.tryParse(env(key)) ?? fallback;
}
