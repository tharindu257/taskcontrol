import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.data(null)) {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final hasTokens = await StorageService.hasTokens();
    if (!hasTokens) return;

    state = const AsyncValue.loading();
    try {
      final user = await _authService.getMe();
      state = AsyncValue.data(user);
    } catch (_) {
      await StorageService.clearTokens();
      state = const AsyncValue.data(null);
    }
  }

  Future<String?> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.login(email: email, password: password);
      state = AsyncValue.data(user);
      return null;
    } catch (e) {
      state = const AsyncValue.data(null);
      if (e is DioException && e.response?.data != null) {
        return e.response?.data['message'] ?? 'Login failed. Please try again.';
      }
      return 'Login failed. Please try again.';
    }
  }

  Future<String?> register({
    required String email,
    required String username,
    required String password,
    String? fullName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.register(
        email: email,
        username: username,
        password: password,
        fullName: fullName,
      );
      state = AsyncValue.data(user);
      return null;
    } catch (e) {
      state = const AsyncValue.data(null);
      if (e is DioException && e.response?.data != null) {
        return e.response?.data['message'] ?? 'Registration failed. Please try again.';
      }
      return 'Registration failed. Please try again.';
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
  }
}
