import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final isAuthResult = await authRepository.isAuthenticated();
    isAuthResult.fold((failure) => emit(AuthUnauthenticated()), (isAuth) async {
      if (isAuth) {
        final userResult = await authRepository.getCurrentUser();
        userResult.fold(
          (failure) => emit(AuthUnauthenticated()),
          (user) => emit(
            user != null ? AuthAuthenticated(user) : AuthUnauthenticated(),
          ),
        );
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.login(event.email, event.password);
    result.fold((failure) {
      // Extract cleaner error message
      String errorMessage = failure.message;
      if (failure.message.contains('Failed host lookup') ||
          failure.message.contains('connection error')) {
        errorMessage =
            'Unable to connect to server. Please check your internet connection.';
      }
      emit(AuthError(errorMessage));
    }, (user) => emit(AuthAuthenticated(user)));
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.signup(
      name: event.name,
      email: event.email,
      password: event.password,
      phone: event.phone,
    );
    result.fold((failure) {
      // Extract cleaner error message
      String errorMessage = failure.message;
      if (failure.message.contains('Failed host lookup') ||
          failure.message.contains('connection error')) {
        errorMessage =
            'Unable to connect to server. Please check your internet connection.';
      }
      emit(AuthError(errorMessage));
    }, (user) => emit(AuthAuthenticated(user)));
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.logout();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }
}
