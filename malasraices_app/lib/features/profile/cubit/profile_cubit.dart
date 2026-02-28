import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(ProfileInitial());

  final ProfileRepository _profileRepository;

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final user = await _profileRepository.getProfile();
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(const ProfileError('Error al cargar el perfil'));
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final currentState = state;
    final currentUser = currentState is ProfileLoaded
        ? currentState.user
        : currentState is ProfileUpdateSuccess
            ? currentState.user
            : null;

    if (currentUser != null) {
      emit(ProfileUpdating(currentUser));
    }

    try {
      final user = await _profileRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      emit(ProfileUpdateSuccess(user));
    } catch (e) {
      emit(const ProfileError('Error al actualizar el perfil'));
    }
  }
}
