import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordState {
  final bool isLoading;
  final String? error;
  final bool isCodeSent;
  final bool isSuccess;

  ForgotPasswordState({
    this.isLoading = false,
    this.error,
    this.isCodeSent = false,
    this.isSuccess = false,
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? error,
    bool? isCodeSent,
    bool? isSuccess,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isCodeSent: isCodeSent ?? this.isCodeSent,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  final AuthRepository _repository;

  ForgotPasswordNotifier(this._repository) : super(ForgotPasswordState());

  Future<void> sendResetCode(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.forgotPassword(email);
      state = state.copyWith(isLoading: false, isCodeSent: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> resetPassword(String email, String token, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.resetPassword(email, token, newPassword);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  void resetState() {
    state = ForgotPasswordState();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final forgotPasswordProvider = StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return ForgotPasswordNotifier(repository);
});
