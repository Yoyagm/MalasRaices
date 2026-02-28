import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/user_model.dart';
import '../data/auth_local_storage.dart';
import '../data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
    required AuthLocalStorage authLocalStorage,
  })  : _authRepository = authRepository,
        _authLocalStorage = authLocalStorage,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _authRepository;
  final AuthLocalStorage _authLocalStorage;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final hasTokens = await _authLocalStorage.hasTokens();
    if (!hasTokens) {
      emit(AuthUnauthenticated());
      return;
    }

    try {
      // Validate access token by fetching profile
      final user = await _authRepository.getProfile();
      emit(AuthAuthenticated(user));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Access token expired — attempt refresh
        try {
          final refreshToken = await _authLocalStorage.getRefreshToken();
          if (refreshToken == null) {
            await _authLocalStorage.clearTokens();
            emit(AuthUnauthenticated());
            return;
          }

          final tokens = await _authRepository.refreshToken(refreshToken);
          await _authLocalStorage.saveTokens(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
          );

          // Retry profile with new token
          final user = await _authRepository.getProfile();
          emit(AuthAuthenticated(user));
        } catch (_) {
          await _authLocalStorage.clearTokens();
          emit(AuthUnauthenticated());
        }
      } else {
        await _authLocalStorage.clearTokens();
        emit(AuthUnauthenticated());
      }
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      await _authLocalStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      emit(AuthAuthenticated(result.user));
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Error al iniciar sesión';
      emit(AuthError(message is List ? message.first : message.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.register(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        role: event.role,
      );

      await _authLocalStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      emit(AuthAuthenticated(result.user));
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Error al registrar';
      emit(AuthError(message is List ? message.first : message.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authLocalStorage.clearTokens();
    emit(AuthUnauthenticated());
  }
}
