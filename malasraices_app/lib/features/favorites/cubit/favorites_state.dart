import 'package:equatable/equatable.dart';

import '../../../core/models/property_model.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded(this.properties);
  final List<PropertyModel> properties;

  bool isFavorite(String propertyId) {
    return properties.any((p) => p.id == propertyId);
  }

  @override
  List<Object> get props => [properties];
}

class FavoritesError extends FavoritesState {
  const FavoritesError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
