sealed class Failure {
  const Failure(this.message);
  final String message;

  String get userMessage => switch (this) {
        NetworkFailure() => 'تعذّر الاتصال بالشبكة',
        ServerFailure() => 'حدث خطأ في الخادم',
        CacheFailure() => 'خطأ في البيانات المحلية',
        UnknownFailure() => 'حدث خطأ غير متوقع',
      };
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {this.statusCode});
  final int? statusCode;
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});
  final int? statusCode;
}

final class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

final class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
