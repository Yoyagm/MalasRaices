import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../core/models/property_model.dart';
import '../data/search_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required SearchRepository searchRepository})
      : _searchRepository = searchRepository,
        super(const SearchState()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: _debounce(const Duration(milliseconds: 400)),
    );
    on<SearchFiltersApplied>(_onFiltersApplied);
    on<SearchNextPageRequested>(_onNextPage);
    on<SearchRefreshRequested>(_onRefresh);
  }

  final SearchRepository _searchRepository;

  EventTransformer<T> _debounce<T>(Duration duration) {
    return (events, mapper) =>
        events.debounce(duration).switchMap(mapper);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(query: event.query, page: 1));
    await _performSearch(emit, reset: true);
  }

  Future<void> _onFiltersApplied(
    SearchFiltersApplied event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(
      type: event.type,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      bedrooms: event.bedrooms,
      bathrooms: event.bathrooms,
      sort: event.sort,
      page: 1,
    ));
    await _performSearch(emit, reset: true);
  }

  Future<void> _onNextPage(
    SearchNextPageRequested event,
    Emitter<SearchState> emit,
  ) async {
    if (state.hasReachedMax) return;
    emit(state.copyWith(page: state.page + 1));
    await _performSearch(emit, reset: false);
  }

  Future<void> _onRefresh(
    SearchRefreshRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(page: 1));
    await _performSearch(emit, reset: true);
  }

  Future<void> _performSearch(Emitter<SearchState> emit,
      {required bool reset}) async {
    emit(state.copyWith(status: SearchStatus.loading));
    try {
      final result = await _searchRepository.search(
        query: state.query.isEmpty ? null : state.query,
        type: state.type,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        bedrooms: state.bedrooms,
        bathrooms: state.bathrooms,
        page: state.page,
        sort: state.sort,
      );

      emit(state.copyWith(
        status: SearchStatus.success,
        properties: reset
            ? result.data
            : [...state.properties, ...result.data],
        hasReachedMax: !result.meta.hasNext,
        total: result.meta.total,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SearchStatus.failure,
        errorMessage: 'Error al buscar propiedades',
      ));
    }
  }
}
