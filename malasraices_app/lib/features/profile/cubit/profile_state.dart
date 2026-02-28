import 'package:equatable/equatable.dart';

import '../../../core/models/user_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.user);
  final UserModel user;

  @override
  List<Object> get props => [user];
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating(this.user);
  final UserModel user;

  @override
  List<Object> get props => [user];
}

class ProfileUpdateSuccess extends ProfileState {
  const ProfileUpdateSuccess(this.user);
  final UserModel user;

  @override
  List<Object> get props => [user];
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
