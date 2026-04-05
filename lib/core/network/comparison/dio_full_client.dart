// ═════════════════════════════════════════════════════════════════════════════
//  DioFullClient  —  كل فيتشرز Dio في مكان واحد
//
//  ✔  SSL Pinning       → IOHttpClientAdapter + SecurityContext        (~6 lines)
//  ✔  Auth injection    → Interceptor.onRequest override               (~8 lines)
//  ✔  Logging           → Interceptor.onRequest/onResponse/onError     (~15 lines)
//  ✔  Retry + back-off  → Interceptor.onError + _dio.fetch()           (~20 lines)
//  ✔  Timeouts          → BaseOptions fields                            (~3 lines)
//  ✔  CancelToken       → built-in, just pass to every call            (~5 lines)
//  ✔  Multipart upload  → FormData.fromMap  ONE constructor call       (~6 lines)
//  ✔  Error handling    → DioException.type enum                       (~3 lines)
//
//  ──────────────────────────────────────────────────────────────────────────
//  إجمالي الكود اللازم لكل الفيتشرز ≈ 220 سطر (بما فيها الـ interceptors).
//  نفس الفيتشرز في dart:io → انظر dart_io_full_client.dart ≈ 430 سطر.
// ═════════════════════════════════════════════════════════════════════════════

import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' as d;
import 'package:dio/io.dart'; // IOHttpClientAdapter

import 'network_client_interface.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DioFullClient
// ─────────────────────────────────────────────────────────────────────────────

class DioFullClient implements NetworkClient {
  DioFullClient({
    required String baseUrl,

    /// DER-encoded bytes of the server certificate you want to pin.
    /// Load it with: File('assets/cert.der').readAsBytesSync()
    List<Uint8List> pinnedCertsDer = const [],

    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 30),
    Duration sendTimeout = const Duration(seconds: 30),
    int maxRetries = 3,
    bool enableLogging = true,
  }) {
    // ── Dio instance with base configuration ─────────────────────────────────
    _dio = d.Dio(
      d.BaseOptions(
        baseUrl: baseUrl,
        // ✔ TIMEOUTS — 3 lines, Dio handles all 3 timeout phases
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
        responseType: d.ResponseType.json,
      ),
    );

    // ── ✔ SSL PINNING ──────────────────────────────────────────────────────────
    // Dio doesn't support pinning natively.
    // We reach into its dart:io layer via IOHttpClientAdapter.
    //
    //  SecurityContext(withTrustedRoots: false)
    //    → reject ALL certificates except what we explicitly load.
    //    → no system CA store, no MITM possible through a rogue CA.
    //
    //  Weakness: we still rely on Dio's internal machinery to call this.
    //  A determined attacker patching the Dio source can bypass it.
    //  dart:io approach (see other file) removes Dio as a middleman.
    if (pinnedCertsDer.isNotEmpty) {
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final ctx = SecurityContext(withTrustedRoots: false);
          for (final der in pinnedCertsDer) {
            ctx.setTrustedCertificatesBytes(der);
          }
          return HttpClient(context: ctx); // only our cert is trusted
        },
      );
    }

    // ── ✔ INTERCEPTORS ─────────────────────────────────────────────────────────
    // Dio runs them in order for requests, reversed for responses.
    // Each is a separate class with clean separation of concerns.
    _dio.interceptors.addAll([
      if (enableLogging) _LoggingInterceptor(),
      _AuthInterceptor(tokenGetter: () => _authToken),
      _RetryInterceptor(dio: _dio, maxRetries: maxRetries),
    ]);
  }

  late final d.Dio _dio;
  String? _authToken;

  // ── Auth ──────────────────────────────────────────────────────────────────
  @override
  void setAuthToken(String token) => _authToken = token;

  @override
  void clearAuthToken() => _authToken = null;

  // ── GET ───────────────────────────────────────────────────────────────────
  @override
  Future<NetworkResponse> get(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? extraHeaders,
    CancelToken? cancelToken,
  }) async {
    final sw = Stopwatch()..start();
    try {
      final res = await _dio.get<dynamic>(
        path,
        queryParameters: queryParams,
        options: d.Options(headers: extraHeaders),
        cancelToken: _bridge(cancelToken), // ✔ CANCEL
      );
      return _wrap(res, path, sw.elapsedMilliseconds);
    } on d.DioException catch (e) {
      throw _toException(e);
    }
  }

  // ── POST ──────────────────────────────────────────────────────────────────
  @override
  Future<NetworkResponse> post(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? extraHeaders,
    CancelToken? cancelToken,
  }) async {
    final sw = Stopwatch()..start();
    try {
      final res = await _dio.post<dynamic>(
        path,
        data: body, // Dio auto-encodes to JSON
        options: d.Options(headers: extraHeaders),
        cancelToken: _bridge(cancelToken),
      );
      return _wrap(res, path, sw.elapsedMilliseconds);
    } on d.DioException catch (e) {
      throw _toException(e);
    }
  }

  // ── PUT ───────────────────────────────────────────────────────────────────
  @override
  Future<NetworkResponse> put(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? extraHeaders,
    CancelToken? cancelToken,
  }) async {
    final sw = Stopwatch()..start();
    try {
      final res = await _dio.put<dynamic>(
        path,
        data: body,
        options: d.Options(headers: extraHeaders),
        cancelToken: _bridge(cancelToken),
      );
      return _wrap(res, path, sw.elapsedMilliseconds);
    } on d.DioException catch (e) {
      throw _toException(e);
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  @override
  Future<NetworkResponse> delete(
    String path, {
    Map<String, String>? extraHeaders,
    CancelToken? cancelToken,
  }) async {
    final sw = Stopwatch()..start();
    try {
      final res = await _dio.delete<dynamic>(
        path,
        options: d.Options(headers: extraHeaders),
        cancelToken: _bridge(cancelToken),
      );
      return _wrap(res, path, sw.elapsedMilliseconds);
    } on d.DioException catch (e) {
      throw _toException(e);
    }
  }

  // ── ✔ MULTIPART UPLOAD ────────────────────────────────────────────────────
  // Dio handles boundary generation, MIME headers, binary encoding — ONE call.
  // Compare this to the 60+ lines needed in dart:io (see other file).
  @override
  Future<NetworkResponse> uploadMultipart(
    String path, {
    required Map<String, String> fields,
    required List<MultipartFileData> files,
    CancelToken? cancelToken,
  }) async {
    final sw = Stopwatch()..start();

    // ↓ ONE constructor handles everything: boundary, MIME headers, binary data
    final formData = d.FormData.fromMap({
      ...fields,
      for (final f in files)
        f.fieldName: d.MultipartFile.fromBytes(f.bytes, filename: f.filename),
    });

    try {
      final res = await _dio.post<dynamic>(
        path,
        data: formData,
        cancelToken: _bridge(cancelToken),
        onSendProgress: (sent, total) => dev.log(
          '⬆ ${(sent / total * 100).toStringAsFixed(1)}%',
          name: 'DioFullClient',
        ),
      );
      return _wrap(res, path, sw.elapsedMilliseconds);
    } on d.DioException catch (e) {
      throw _toException(e);
    }
  }

  // ── Close ─────────────────────────────────────────────────────────────────
  @override
  void close() => _dio.close(force: true);

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Bridge our CancelToken to Dio's CancelToken so both stay in sync.
  d.CancelToken? _bridge(CancelToken? token) {
    if (token == null) return null;
    final dioToken = d.CancelToken();
    token.onCancel = (reason) => dioToken.cancel(reason);
    return dioToken;
  }

  NetworkResponse _wrap(d.Response<dynamic> r, String path, int ms) =>
      NetworkResponse(
        statusCode: r.statusCode ?? 200,
        data: r.data,
        headers: r.headers.map,
        requestPath: path,
        durationMs: ms,
      );

  /// ✔ ERROR HANDLING — Dio normalizes ALL errors into one DioException type.
  NetworkException _toException(d.DioException e) {
    // e.type is an enum: connectionError, badCertificate, receiveTimeout, etc.
    if (e.type == d.DioExceptionType.cancel) {
      return NetworkException(message: 'Request cancelled', statusCode: -2);
    }
    if (e.type == d.DioExceptionType.badCertificate) {
      return NetworkException(message: 'SSL certificate rejected', statusCode: -3);
    }
    return NetworkException(
      message: e.message ?? e.type.name,
      statusCode: e.response?.statusCode ?? -1,
      data: e.response?.data,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  INTERCEPTORS  —  Dio gives you a clean abstract class to override.
//  Each concern is one class, ~10 lines each.
// ═════════════════════════════════════════════════════════════════════════════

// ── ✔ Auth Interceptor ────────────────────────────────────────────────────────
class _AuthInterceptor extends d.Interceptor {
  _AuthInterceptor({required String? Function() tokenGetter})
      : _token = tokenGetter;

  final String? Function() _token;

  @override
  void onRequest(d.RequestOptions options, d.RequestInterceptorHandler handler) {
    final token = _token();
    if (token != null) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    handler.next(options); // pass to next interceptor
  }
}

// ── ✔ Logging Interceptor ─────────────────────────────────────────────────────
class _LoggingInterceptor extends d.Interceptor {
  static const _tag = 'DioFullClient';

  @override
  void onRequest(d.RequestOptions o, d.RequestInterceptorHandler h) {
    dev.log('→ ${o.method} ${o.uri}  body: ${o.data}', name: _tag);
    h.next(o);
  }

  @override
  void onResponse(d.Response<dynamic> r, d.ResponseInterceptorHandler h) {
    dev.log('← ${r.statusCode} ${r.requestOptions.path}', name: _tag);
    h.next(r);
  }

  @override
  void onError(d.DioException e, d.ErrorInterceptorHandler h) {
    dev.log('✗ ${e.type.name}: ${e.message}', name: _tag, level: 1000);
    h.next(e);
  }
}

// ── ✔ Retry Interceptor ───────────────────────────────────────────────────────
// Retries on network errors + 5xx with exponential back-off.
// Dio lets us re-run the request with _dio.fetch(options) from inside onError.
class _RetryInterceptor extends d.Interceptor {
  _RetryInterceptor({required d.Dio dio, required int maxRetries})
      : _dio = dio,
        _max = maxRetries;

  final d.Dio _dio;
  final int _max;

  @override
  Future<void> onError(d.DioException err, d.ErrorInterceptorHandler h) async {
    final opts = err.requestOptions;
    final attempt = (opts.extra['_retry'] as int?) ?? 0;

    final shouldRetry = attempt < _max &&
        (err.type == d.DioExceptionType.connectionError ||
            err.type == d.DioExceptionType.receiveTimeout ||
            (err.response?.statusCode ?? 0) >= 500);

    if (!shouldRetry) {
      h.next(err);
      return;
    }

    // Exponential back-off: 1 s → 2 s → 4 s …
    final delay = Duration(seconds: 1 << attempt);
    dev.log('↻ Retry ${attempt + 1}/$_max in ${delay.inSeconds}s',
        name: 'DioFullClient');
    await Future<void>.delayed(delay);

    opts.extra['_retry'] = attempt + 1;
    try {
      h.resolve(await _dio.fetch<dynamic>(opts)); // re-run same request
    } on d.DioException catch (e) {
      h.next(e);
    }
  }
}
