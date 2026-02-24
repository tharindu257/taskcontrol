import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final _api = ApiService();

  Future<User> register({
    required String email,
    required String username,
    required String password,
    String? fullName,
  }) async {
    final response = await _api.post('/auth/register', data: {
      'email': email,
      'username': username,
      'password': password,
      if (fullName != null) 'fullName': fullName,
    });

    final data = response['data'];
    await StorageService.saveTokens(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );

    return User.fromJson(data['user']);
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    final data = response['data'];
    await StorageService.saveTokens(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );

    return User.fromJson(data['user']);
  }

  Future<User> getMe() async {
    final response = await _api.get('/auth/me');
    return User.fromJson(response['data']);
  }

  Future<void> logout() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken != null) {
        await _api.post('/auth/logout', data: {'refreshToken': refreshToken});
      }
    } catch (_) {}
    await StorageService.clearTokens();
  }
}
