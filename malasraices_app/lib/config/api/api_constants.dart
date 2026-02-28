class ApiConstants {
  ApiConstants._();

  // En Android emulator, 10.0.2.2 apunta al localhost de la máquina host
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';

  // Users
  static const String profile = '/users/me';

  // Properties
  static const String properties = '/properties';
  static String propertyById(String id) => '/properties/$id';
  static String propertyImages(String id) => '/properties/$id/images';

  // Search
  static const String search = '/search';

  // Favorites
  static const String favorites = '/favorites';
  static String favoriteById(String propertyId) => '/favorites/$propertyId';
}
