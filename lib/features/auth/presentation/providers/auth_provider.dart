import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth state notifier for managing auth UI state
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading, error: null);
  }

  void setError(String? error) {
    state = state.copyWith(isLoading: false, error: error);
  }

  void setSuccess() {
    state = state.copyWith(isLoading: false, error: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearMessage() {
    state = state.copyWith(message: null);
  }
}

/// Auth state class
class AuthState {
  final bool isLoading;
  final String? error;
  final String? message;

  const AuthState({this.isLoading = false, this.error, this.message});

  AuthState copyWith({bool? isLoading, String? error, String? message}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      message: message,
    );
  }
}

/// Provider for the auth notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier();
});
