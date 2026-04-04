import 'package:dio/dio.dart';
import '../../error/exceptions.dart';

/// Converts DioException into domain-specific exceptions.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return handler.reject(
          err.copyWith(
            error: NetworkException(
              message: 'Connection timeout',
              statusCode: err.response?.statusCode,
            ),
          ),
        );
      case DioExceptionType.badResponse:
        return handler.reject(
          err.copyWith(
            error: ServerException(
              message: err.response?.data?['message'] as String? ?? 'Server error',
              statusCode: err.response?.statusCode,
            ),
          ),
        );
      case DioExceptionType.connectionError:
        return handler.reject(
          err.copyWith(
            error: const NetworkException(message: 'No internet connection'),
          ),
        );
      default:
        return handler.reject(
          err.copyWith(
            error: NetworkException(
              message: err.message ?? 'Unknown network error',
            ),
          ),
        );
    }
  }
}
