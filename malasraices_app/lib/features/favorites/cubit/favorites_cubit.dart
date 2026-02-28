import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/favorites_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({required FavoritesRepository favoritesRepository})
      : _favoritesRepository = favoritesRepository,
        super(FavoritesInitial());

  final FavoritesRepository _favoritesRepository;

  Future<void> loadFavorites() async {
    emit(FavoritesLoading());
    try {
      final favorites = await _favoritesRepository.getAll();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(const FavoritesError('Error al cargar favoritos'));
    }
  }

  Future<void> toggleFavorite(String propertyId) async {
    final currentState = state;
    if (currentState is! FavoritesLoaded) return;

    try {
      if (currentState.isFavorite(propertyId)) {
        await _favoritesRepository.remove(propertyId);
      } else {
        await _favoritesRepository.add(propertyId);
      }
      await loadFavorites();
    } catch (e) {
      emit(const FavoritesError('Error al actualizar favorito'));
    }
  }
}
