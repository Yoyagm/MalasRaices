import 'package:equatable/equatable.dart';

import '../../../core/models/property_model.dart';

abstract class PropertyListState extends Equatable {
  const PropertyListState();

  @override
  List<Object?> get props => [];
}

class PropertyListInitial extends PropertyListState {}

class PropertyListLoading extends PropertyListState {}

class PropertyListLoaded extends PropertyListState {
  const PropertyListLoaded(this.properties);
  final List<PropertyModel> properties;

  @override
  List<Object> get props => [properties];
}

class PropertyListError extends PropertyListState {
  const PropertyListError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
