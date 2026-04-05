// ─────────────────────────────────────────────────────────────────────────────
// Shared types used by BOTH DioFullClient and DartIoFullClient.
// Having one interface makes the feature-parity comparison exact.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:typed_data';

// ── Response model ────────────────────────────────────────────────────────────

class NetworkResponse {
  const NetworkResponse({
    required this.statusCode,
    required this.data,
    required this.headers,
    required this.requestPath,
    required this.durationMs,
  });

  final int statusCode;
  final dynamic data; // Map / List / String depending on Content-Type
  final Map<String, List<String>> headers;
  final String requestPath;
  final int durationMs;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  @override
  String toString() =>
      'NetworkResponse($statusCode  $requestPath  ${durationMs}ms)';
}

// ── Exception model ───────────────────────────────────────────────────────────

class NetworkException implements Exception {
  const NetworkException({
    required this.message,
    this.statusCode = -1,
    this.data,
  });

  final String message;
  final int statusCode; // -1 = no response, -2 = cancelled, -3 = SSL error
  final dynamic data;

  @override
  String toString() => 'NetworkException($statusCode): $message';
}

// ── Cancel token ──────────────────────────────────────────────────────────────
// The client wires [onCancel] to its transport layer (Dio's CancelToken or
// HttpClientRequest.abort()) so that cancel() immediately halts the I/O.

class CancelToken {
  bool _cancelled = false;
  String? _reason;

  bool get isCancelled => _cancelled;
  String? get reason => _reason;

  /// Set by the client to propagate the cancel signal to the transport.
  void Function(String? reason)? onCancel;

  void cancel([String? reason]) {
    if (_cancelled) return;
    _cancelled = true;
    _reason = reason;
    onCancel?.call(reason);
  }
}

// ── Multipart file descriptor ─────────────────────────────────────────────────

class MultipartFileData {
  const MultipartFileData({
    required this.fieldName,
    required this.filename,
    required this.bytes,
    this.contentType = 'application/octet-stream',
  });

  final String fieldName;
  final String filename;
  final Uint8List bytes;
  final String contentType;
}

// ── Unified client interface ──────────────────────────────────────────────────

abstract interface class NetworkClient {
  Future<NetworkResponse> get(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? extraHeaders,
    CancelToken? cancelToken,
  });

  Future<NetworkResponse> post(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? extraHeaders,
    CancelToken? cancelToken,
  });

  Future<NetworkResponse> put(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? extraHeaders,
    CancelToken? cancelToken,
  });

  Future<NetworkResponse> delete(
    String path, {
    Map<String, String>? extraHeaders,
    CancelToken? cancelToken,
  });

  Future<NetworkResponse> uploadMultipart(
    String path, {
    required Map<String, String> fields,
    required List<MultipartFileData> files,
    CancelToken? cancelToken,
  });

  void setAuthToken(String token);
  void clearAuthToken();
  void close();
}
