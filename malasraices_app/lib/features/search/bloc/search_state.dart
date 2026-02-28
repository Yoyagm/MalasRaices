part of 'search_bloc.dart';

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.properties = const [],
    this.query = '',
    this.type,
    this.minPrice,
    this.maxPrice,
    this.bedrooms,
    this.bathrooms,
    this.sort = 'newest',
    this.page = 1,
    this.hasReachedMax = false,
    this.total = 0,
    this.errorMessage,
  });

  final SearchStatus status;
  final List<PropertyModel> properties;
  final String query;
  final String? type;
  final double? minPrice;
  final double? maxPrice;
  final int? bedrooms;
  final int? bathrooms;
  final String sort;
  final int page;
  final bool hasReachedMax;
  final int total;
  final String? errorMessage;

  SearchState copyWith({
    SearchStatus? status,
    List<PropertyModel>? properties,
    String? query,
    String? type,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int? bathrooms,
    String? sort,
    int? page,
    bool? hasReachedMax,
    int? total,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      query: query ?? this.query,
      type: type ?? this.type,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      sort: sort ?? this.sort,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      total: total ?? this.total,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        properties,
        query,
        type,
        minPrice,
        maxPrice,
        bedrooms,
        bathrooms,
        sort,
        page,
        hasReachedMax,
        total,
        errorMessage,
      ];
}

enum SearchStatus { initial, loading, success, failure }
