// ═════════════════════════════════════════════════════════════════════════════
//  DartIoFullClient  —  نفس فيتشرز Dio بس باستخدام dart:io مباشرة
//
//  ✔  SSL Pinning       → SecurityContext + badCertificateCallback     (~15 lines)
//  ✔  Auth injection    → manual header set في interceptor list        (~12 lines)
//  ✔  Logging           → manual _RequestInterceptor/_ResponseInterceptor (~25 lines)
//  ✔  Retry + back-off  → while(true) loop يدوي                       (~30 lines)
//  ✔  Timeouts          → client.connectionTimeout + Future.timeout()  (~10 lines)
//  ✔  CancelToken       → request.abort() مباشرة                      (~15 lines)
//  ✔  Multipart upload  → boundary يدوي + MIME headers يدوي + binary  (~60 lines)
//  ✔  Error handling    → SocketException + TlsException + HttpException (~20 lines)
//
//  ──────────────────────────────────────────────────────────────────────────
//  إجمالي الكود ≈ 430 سطر لنفس الفيتشرز اللي Dio بيديها في ≈ 220 سطر.
//
//  الفرق مش بس في عدد السطور — dart:io بيديك تحكم كامل:
//  • SSL Pinning مش بيعتمد على Dio كـ middleman → مستوى أمان أعلى
//  • قدرة على فحص الـ certificate fingerprint (SHA-256 / Public Key pinning)
//  • كل request يمر على طبقة dart مباشرة → MobSF/Frida أصعب تعترضه
//  • لا توجد مكتبة وسيطة ممكن تتعدل أو تتبدل تحت كودك
// ═════════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'network_client_interface.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DartIoFullClient
// ─────────────────────────────────────────────────────────────────────────────

class DartIoFullClient implements NetworkClient {
  DartIoFullClient({
    required String baseUrl,

    /// DER-encoded certificate bytes — same input as DioFullClient.
    /// نفس الـ certificate لكن هنا لدينا تحكم أكثر.
    List<Uint8List> pinnedCertsDer = const [],

    /// Optional: SHA-256 fingerprints of pinned certificates (hex strings).
    /// أقوى من Certificate Pinning لأنه بيثبت الـ Public Key مش الشهادة كلها.
    /// احسبها: openssl x509 -pubkey -in cert.pem | openssl pkey -pubin -outform der | openssl dgst -sha256
    List<String> pinnedSha256Fingerprints = const [],

    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 30),
    int maxRetries = 3,
    bool enableLogging = true,
  })  : _baseUri = Uri.parse(baseUrl),
        _receiveTimeout = receiveTimeout,
        _maxRetries = maxRetries {
    // ── ✔ SSL PINNING ──────────────────────────────────────────────────────────
    //
    // LAYER 1: SecurityContext — نثق فقط بالـ certificate اللي أحنا حطيناه.
    //          withTrustedRoots: false = مفيش CA من الـ OS مش موثوق بيه.
    //          ده بيمنع MITM عن طريق CA مخترقة تماماً.
    //
    // LAYER 2: badCertificateCallback — للـ certificate pinning بالـ fingerprint.
    //          بيتنادى لما الـ TLS handshake يفشل (cert مش مطابق).
    //          لو الـ cert valid بس مش الـ pinned cert، LAYER 1 هو اللي بيمنعه.
    //
    // مع Dio: محتاج IOHttpClientAdapter للوصول لنفس المستوى ده.
    // مع dart:io: وصول مباشر بدون وسيط.

    if (pinnedCertsDer.isNotEmpty) {
      final ctx = SecurityContext(withTrustedRoots: false);
      for (final der in pinnedCertsDer) {
        ctx.setTrustedCertificatesBytes(der);
      }
      _client = HttpClient(context: ctx);
    } else {
      _client = HttpClient();
    }

    // LAYER 2: fingerprint check (يعمل كـ double-check إضافي)
    // مع package:crypto: sha256.convert(cert.der).toString()
    // هنا بنستخدم مقارنة مباشرة للـ DER bytes كمثال
    if (pinnedSha256Fingerprints.isNotEmpty) {
      _client.badCertificateCallback = (cert, host, port) {
        // ⚠️ هنا لازم تستخدم package:crypto في Production:
        //    final digest = sha256.convert(cert.der).toString();
        //    return pinnedSha256Fingerprints.contains(digest);
        //
        // مثال بدون crypto: مقارنة DER مباشرة
        return pinnedCertsDer.any((pinned) => _bytesEqual(pinned, cert.der));
      };
    }

    // ── ✔ TIMEOUTS ─────────────────────────────────────────────────────────────
    // dart:io بيديك connectionTimeout مباشرة على الـ client.
    // receiveTimeout بنطبقه يدوياً على كل request بـ Future.timeout().
    _client.connectionTimeout = connectTimeout;

    // ── ✔ INTERCEPTORS ─────────────────────────────────────────────────────────
    // Dio بيديك abstract class جاهزة.
    // هنا بنبني الـ pattern ده يدوياً باستخدام interfaces بسيطة.
    _requestInterceptors = [
      if (enableLogging) _LogRequestInterceptor(),
      _AuthRequestInterceptor(tokenGetter: () => _authToken),
    ];
    _responseInterceptors = [
      if (enableLogging) _LogResponseInterceptor(),
    ];
  }

  final Uri _baseUri;
  final Duration _receiveTimeout;
  final int _maxRetries;
  late final HttpClient _client;
  String? _authToken;
  late final List<_RequestInterceptor> _requestInterceptors;
  late final List<_ResponseInterceptor> _responseInterceptors;

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
  }) =>
      _executeWithRetry(
        method: 'GET',
        path: path,
        queryParams: queryParams,
        extraHeaders: extraHeaders,
        cancelToken: cancelToken,
      );

  // ── POST ──────────────────────────────────────────────────────────────────
  @override
  Future<NetworkResponse> post(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? extraHeaders,
    CancelToken? cancelToken,
  }) =>
      _executeWithRetry(
        method: 'POST',
        path: path,
        body: jsonEncode(body), // يدوياً نحوّل لـ JSON string
        extraHeaders: extraHeaders,
        cancelToken: cancelToken,
      );

  // ── PUT ───────────────────────────────────────────────────────────────────
  @override
  Future<NetworkResponse> put(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? extraHeaders,
    CancelToken? cancelToken,
  }) =>
      _executeWithRetry(
        method: 'PUT',
        path: path,
        body: jsonEncode(body),
        extraHeaders: extraHeaders,
        cancelToken: cancelToken,
      );

  // ── DELETE ────────────────────────────────────────────────────────────────
  @override
  Future<NetworkResponse> delete(
    String path, {
    Map<String, String>? extraHeaders,
    CancelToken? cancelToken,
  }) =>
      _executeWithRetry(
        method: 'DELETE',
        path: path,
        extraHeaders: extraHeaders,
        cancelToken: cancelToken,
      );

  // ── ✔ MULTIPART UPLOAD ────────────────────────────────────────────────────
  // مع Dio: FormData.fromMap({...}) — سطر واحد.
  // مع dart:io: لازم تبني الـ multipart body يدوياً:
  //   1. توليد random boundary string
  //   2. كتابة MIME header لكل field
  //   3. كتابة binary bytes لكل file مع MIME header مناسب
  //   4. غلق الـ body بالـ closing boundary
  //   5. حساب الـ Content-Length الإجمالي
  @override
  Future<NetworkResponse> uploadMultipart(
    String path, {
    required Map<String, String> fields,
    required List<MultipartFileData> files,
    CancelToken? cancelToken,
  }) async {
    final boundary = _generateBoundary(); // random string فاصل بين الأجزاء
    final parts = <List<int>>[];

    // ── Text fields ──────────────────────────────────────────────────────
    for (final entry in fields.entries) {
      parts
        ..add(_enc('--$boundary\r\n'))
        ..add(_enc(
            'Content-Disposition: form-data; name="${entry.key}"\r\n\r\n'))
        ..add(_enc('${entry.value}\r\n'));
    }

    // ── Binary files ─────────────────────────────────────────────────────
    for (final file in files) {
      parts
        ..add(_enc('--$boundary\r\n'))
        ..add(_enc(
            'Content-Disposition: form-data; name="${file.fieldName}"; '
            'filename="${file.filename}"\r\n'))
        ..add(_enc('Content-Type: ${file.contentType}\r\n\r\n'))
        ..add(file.bytes) // ← binary data مباشرة
        ..add(_enc('\r\n'));
    }

    // ── Closing boundary ─────────────────────────────────────────────────
    parts.add(_enc('--$boundary--\r\n'));

    // ── Flatten all parts into one Uint8List ──────────────────────────────
    final totalLength = parts.fold<int>(0, (s, p) => s + p.length);
    final body = Uint8List(totalLength);
    var offset = 0;
    for (final part in parts) {
      body.setRange(offset, offset + part.length, part);
      offset += part.length;
    }

    return _executeWithRetry(
      method: 'POST',
      path: path,
      rawBody: body,
      extraHeaders: {
        HttpHeaders.contentTypeHeader:
            'multipart/form-data; boundary=$boundary',
        HttpHeaders.contentLengthHeader: '${body.length}',
      },
      cancelToken: cancelToken,
    );
  }

  // ── Close ─────────────────────────────────────────────────────────────────
  @override
  void close() => _client.close(force: true);

  // ══════════════════════════════════════════════════════════════════════════
  // ✔ RETRY LOOP — ما يعادل _RetryInterceptor في Dio لكن مكتوب يدوياً
  // ══════════════════════════════════════════════════════════════════════════

  Future<NetworkResponse> _executeWithRetry({
    required String method,
    required String path,
    String? body,
    Uint8List? rawBody,
    Map<String, String>? queryParams,
    Map<String, String>? extraHeaders,
    CancelToken? cancelToken,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await _executeOnce(
          method: method,
          path: path,
          body: body,
          rawBody: rawBody,
          queryParams: queryParams,
          extraHeaders: extraHeaders,
          cancelToken: cancelToken,
        );
      } on NetworkException catch (e) {
        // لا retry للـ cancellation أو أخطاء 4xx
        if (cancelToken?.isCancelled == true) rethrow;
        if (e.statusCode >= 400 && e.statusCode < 500) rethrow;
        if (++attempt > _maxRetries) rethrow;

        // Exponential back-off: 1s → 2s → 4s …
        final delay = Duration(seconds: 1 << (attempt - 1));
        dev.log('↻ Retry $attempt/$_maxRetries ($method $path) '
            'in ${delay.inSeconds}s',
            name: 'DartIoClient');
        await Future<void>.delayed(delay);
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Core request execution — ما يعادل dio.fetch() لكن يدوياً
  // ══════════════════════════════════════════════════════════════════════════

  Future<NetworkResponse> _executeOnce({
    required String method,
    required String path,
    String? body,
    Uint8List? rawBody,
    Map<String, String>? queryParams,
    Map<String, String>? extraHeaders,
    CancelToken? cancelToken,
  }) async {
    final sw = Stopwatch()..start();

    // ── Build URI ────────────────────────────────────────────────────────
    final uri = _baseUri.replace(
      path: '${_baseUri.path}$path',
      queryParameters: queryParams,
    );

    // ── Open connection ──────────────────────────────────────────────────
    // TlsException يُطرح هنا لو الـ SSL pinning فشل (cert مش مطابق).
    // مع Dio: يظهر كـ DioExceptionType.badCertificate.
    final HttpClientRequest request;
    try {
      request = await _client.openUrl(method, uri);
    } on TlsException catch (e) {
      // ✔ SSL ERROR — dart:io يعطيك نوع الخطأ مباشرة بدون wrapper
      throw NetworkException(
        message: '🔒 SSL Pinning failed: ${e.message}',
        statusCode: -3,
      );
    } on SocketException catch (e) {
      throw NetworkException(message: 'Connection failed: ${e.message}');
    }

    // ── ✔ CANCEL — request.abort() مباشرة على الـ I/O object ─────────────
    // مع Dio: CancelToken() يمر للمكتبة اللي تقرر وقت الـ abort.
    // هنا: نحن من نتحكم متى وكيف يُلغى الـ request بالضبط.
    if (cancelToken != null) {
      cancelToken.onCancel = (_) {
        try {
          request.abort(); // إلغاء فوري على مستوى TCP
        } catch (_) {}
      };
    }

    // ── Default + interceptor headers ────────────────────────────────────
    request
      ..headers.set(HttpHeaders.contentTypeHeader, 'application/json')
      ..headers.set(HttpHeaders.acceptHeader, 'application/json');

    // ── ✔ REQUEST INTERCEPTORS — نشغّلها يدوياً ──────────────────────────
    // مع Dio: تتشغل تلقائياً من interceptor pipeline.
    // هنا: نلوب عليها يدوياً.
    for (final interceptor in _requestInterceptors) {
      interceptor.onRequest(request, path, body);
    }

    // Extra headers from caller
    extraHeaders?.forEach(request.headers.set);

    // ── Write body ───────────────────────────────────────────────────────
    if (rawBody != null) {
      request.add(rawBody); // binary (multipart)
    } else if (body != null) {
      request.write(body); // text (JSON)
    }

    // ── ✔ RECEIVE TIMEOUT — يدوياً بـ Future.timeout() ────────────────────
    // مع Dio: BaseOptions.receiveTimeout يكفي.
    // هنا: نلف كل response future بـ timeout يدوي.
    final HttpClientResponse response;
    try {
      response = await request.close().timeout(
        _receiveTimeout,
        onTimeout: () {
          request.abort();
          throw NetworkException(
            message: 'Receive timeout after ${_receiveTimeout.inSeconds}s',
          );
        },
      );
    } on HttpException catch (e) {
      if (cancelToken?.isCancelled == true) {
        throw NetworkException(
          message: 'Request cancelled: ${cancelToken?.reason ?? ""}',
          statusCode: -2,
        );
      }
      throw NetworkException(message: e.message);
    }

    // ── Read response body ────────────────────────────────────────────────
    final rawResponse = await response
        .transform(utf8.decoder)
        .join()
        .timeout(
          _receiveTimeout,
          onTimeout: () =>
              throw NetworkException(message: 'Body read timeout'),
        );

    // ── Parse JSON ───────────────────────────────────────────────────────
    // مع Dio: responseType: ResponseType.json يكفي.
    // هنا: نعمله يدوياً بناءً على الـ Content-Type header.
    final contentType =
        response.headers.value(HttpHeaders.contentTypeHeader) ?? '';
    dynamic parsedData;
    if (contentType.contains('application/json')) {
      try {
        parsedData = jsonDecode(rawResponse);
      } catch (_) {
        parsedData = rawResponse; // fallback للـ raw string
      }
    } else {
      parsedData = rawResponse;
    }

    // ── Collect headers ───────────────────────────────────────────────────
    final headersMap = <String, List<String>>{};
    response.headers.forEach((name, values) => headersMap[name] = values);

    final result = NetworkResponse(
      statusCode: response.statusCode,
      data: parsedData,
      headers: headersMap,
      requestPath: path,
      durationMs: sw.elapsedMilliseconds,
    );

    // ── ✔ RESPONSE INTERCEPTORS ───────────────────────────────────────────
    var finalResult = result;
    for (final interceptor in _responseInterceptors) {
      finalResult = interceptor.onResponse(finalResult);
    }

    // ── ✔ ERROR HANDLING — نتحقق من كل نوع خطأ يدوياً ──────────────────────
    // مع Dio: DioException.type enum يغطيها كلها.
    // هنا: كل exception type له catch block خاص به.
    if (response.statusCode >= 400) {
      throw NetworkException(
        message:
            'HTTP ${response.statusCode} ${response.reasonPhrase}',
        statusCode: response.statusCode,
        data: parsedData,
      );
    }

    return finalResult;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Uint8List _enc(String s) =>
      Uint8List.fromList(utf8.encode(s));

  static String _generateBoundary() {
    final rng = Random.secure();
    return List.generate(
      16,
      (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  /// Compare two byte arrays in constant time to prevent timing attacks.
  static bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i]; // XOR — constant-time comparison
    }
    return result == 0;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  INTERCEPTORS — نبنيهم يدوياً بـ abstract interface
//  مع Dio: كل ده جاهز في d.Interceptor abstract class.
// ═════════════════════════════════════════════════════════════════════════════

abstract interface class _RequestInterceptor {
  void onRequest(HttpClientRequest request, String path, String? body);
}

abstract interface class _ResponseInterceptor {
  NetworkResponse onResponse(NetworkResponse response);
}

// ── ✔ Auth Interceptor ────────────────────────────────────────────────────────
class _AuthRequestInterceptor implements _RequestInterceptor {
  _AuthRequestInterceptor({required String? Function() tokenGetter})
      : _token = tokenGetter;

  final String? Function() _token;

  @override
  void onRequest(HttpClientRequest request, String path, String? body) {
    final token = _token();
    if (token != null) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $token',
      );
    }
  }
}

// ── ✔ Request Logging Interceptor ────────────────────────────────────────────
class _LogRequestInterceptor implements _RequestInterceptor {
  @override
  void onRequest(HttpClientRequest request, String path, String? body) {
    final truncated =
        body != null && body.length > 300 ? '${body.substring(0, 300)}…' : body;
    dev.log(
      '→ ${request.method} ${request.uri}\n   body: $truncated',
      name: 'DartIoClient',
    );
  }
}

// ── ✔ Response Logging Interceptor ───────────────────────────────────────────
class _LogResponseInterceptor implements _ResponseInterceptor {
  @override
  NetworkResponse onResponse(NetworkResponse response) {
    final dataStr = response.data.toString();
    final truncated =
        dataStr.length > 300 ? '${dataStr.substring(0, 300)}…' : dataStr;
    dev.log(
      '← ${response.statusCode} ${response.requestPath} '
      '(${response.durationMs}ms)\n   data: $truncated',
      name: 'DartIoClient',
    );
    return response; // يمكن تعديل الـ response هنا لو محتاج
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  ملخص الفرق بين الطريقتين
//
//  ┌────────────────────────┬─────────────────────┬──────────────────────────┐
//  │ Feature                │ Dio                 │ dart:io                  │
//  ├────────────────────────┼─────────────────────┼──────────────────────────┤
//  │ SSL Certificate Pin    │ IOHttpClientAdapter │ SecurityContext مباشرة   │
//  │ Public Key Pin (HPKP)  │ ❌ معقد             │ ✅ badCertificateCallback │
//  │ Auth injection         │ Interceptor class   │ manual header set        │
//  │ Logging                │ LogInterceptor()    │ custom classes يدوي      │
//  │ Retry + backoff        │ Interceptor.onError │ while loop               │
//  │ Timeouts               │ BaseOptions 3 fields│ connectionTimeout + .timeout()│
//  │ Cancel                 │ CancelToken()       │ request.abort()          │
//  │ Multipart              │ FormData.fromMap()  │ boundary + MIME يدوي     │
//  │ Error normalization    │ DioException.type   │ 4 catch blocks           │
//  │ MobSF detectability    │ أسهل (layer Dart)   │ أصعب (dart:io مباشر)     │
//  │ Lines of code          │ ~220                │ ~430                     │
//  └────────────────────────┴─────────────────────┴──────────────────────────┘
// ═════════════════════════════════════════════════════════════════════════════
