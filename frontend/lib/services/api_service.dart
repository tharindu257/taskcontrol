import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio dio;

  ApiService._internal() {
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Try to refresh the token
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the original request
            final token = await StorageService.getAccessToken();
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await dio.fetch(error.requestOptions);
            return handler.resolve(response);
          }
        }
        handler.next(error);
      },
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio(BaseOptions(baseUrl: AppConfig.baseUrl)).post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.data['success'] == true) {
        await StorageService.saveTokens(
          accessToken: response.data['data']['accessToken'],
          refreshToken: response.data['data']['refreshToken'],
        );
        return true;
      }
      return false;
    } catch (e) {
      await StorageService.clearTokens();
      return false;
    }
  }

  // Generic request methods
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParams}) async {
    final response = await dio.get(path, queryParameters: queryParams);
    return response.data;
  }

  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    final response = await dio.post(path, data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> put(String path, {dynamic data}) async {
    final response = await dio.put(path, data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> patch(String path, {dynamic data}) async {
    final response = await dio.patch(path, data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await dio.delete(path);
    return response.data;
  }
}
