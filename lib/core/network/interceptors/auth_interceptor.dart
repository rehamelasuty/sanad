import 'package:dio/dio.dart';

/// Attaches the Bearer token to every outgoing request.
class AuthInterceptor extends Interceptor {
  // TODO: Replace with secure token storage (e.g., flutter_secure_storage)
  static String? _accessToken;

  static void setToken(String token) => _accessToken = token;
  static void clearToken() => _accessToken = null;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_accessToken != null) {
      options.headers['Authorization'] = 'Bearer $_accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      clearToken();
      // Navigate to login – handled at app level via BLoC app event
    }
    handler.next(err);
  }
}
