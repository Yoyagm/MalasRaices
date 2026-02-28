part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);
  final String query;

  @override
  List<Object> get props => [query];
}

class SearchFiltersApplied extends SearchEvent {
  const SearchFiltersApplied({
    this.type,
    this.minPrice,
    this.maxPrice,
    this.bedrooms,
    this.bathrooms,
    this.sort = 'newest',
  });

  final String? type;
  final double? minPrice;
  final double? maxPrice;
  final int? bedrooms;
  final int? bathrooms;
  final String sort;

  @override
  List<Object?> get props => [type, minPrice, maxPrice, bedrooms, bathrooms, sort];
}

class SearchNextPageRequested extends SearchEvent {}

class SearchRefreshRequested extends SearchEvent {}
