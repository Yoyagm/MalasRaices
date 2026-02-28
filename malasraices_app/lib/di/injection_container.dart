import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../config/api/api_client.dart';
import '../config/api/auth_interceptor.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/data/auth_local_storage.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/favorites/cubit/favorites_cubit.dart';
import '../features/favorites/data/favorites_repository.dart';
import '../features/profile/cubit/profile_cubit.dart';
import '../features/profile/data/profile_repository.dart';
import '../features/properties/cubit/property_detail_cubit.dart';
import '../features/properties/cubit/property_form_cubit.dart';
import '../features/properties/cubit/property_list_cubit.dart';
import '../features/properties/data/properties_repository.dart';
import '../features/search/bloc/search_bloc.dart';
import '../features/search/data/search_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── Core ──────────────────────────────────────────────
  const storage = FlutterSecureStorage();
  sl.registerLazySingleton<FlutterSecureStorage>(() => storage);

  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(storage: sl()),
  );

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(authInterceptor: sl()),
  );

  // ── Data / Repositories ───────────────────────────────
  sl.registerLazySingleton<AuthLocalStorage>(
    () => AuthLocalStorage(storage: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(dio: sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepository(dio: sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<PropertiesRepository>(
    () => PropertiesRepository(dio: sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepository(dio: sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(dio: sl<ApiClient>().dio),
  );

  // ── BLoCs / Cubits ────────────────────────────────────
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: sl(),
      authLocalStorage: sl(),
    ),
  );

  sl.registerFactory<SearchBloc>(
    () => SearchBloc(searchRepository: sl()),
  );

  sl.registerFactory<PropertyListCubit>(
    () => PropertyListCubit(propertiesRepository: sl()),
  );

  sl.registerFactory<FavoritesCubit>(
    () => FavoritesCubit(favoritesRepository: sl()),
  );

  sl.registerFactory<PropertyFormCubit>(
    () => PropertyFormCubit(propertiesRepository: sl()),
  );

  sl.registerLazySingleton<ProfileCubit>(
    () => ProfileCubit(profileRepository: sl()),
  );

  sl.registerFactory<PropertyDetailCubit>(
    () => PropertyDetailCubit(propertiesRepository: sl()),
  );
}
