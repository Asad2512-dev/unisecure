import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../app/config/app_config.dart';
import '../storage/secure_store.dart';

class ApiClient {
  final SecureStore store;
  late final Dio dio;
  ApiClient({Dio? client, SecureStore? secureStore})
    : store = secureStore ?? SecureStore() {
    dio =
        client ??
        Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: AppConfig.requestTimeout,
            receiveTimeout: AppConfig.requestTimeout,
            headers: {'Accept': 'application/json'},
          ),
        );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) async {
          final token = await store.read();
          if (token != null) o.headers['Authorization'] = 'Bearer $token';
          _logRequest(o);
          h.next(o);
        },
        onResponse: (response, h) {
          _logResponse(response);
          h.next(response);
        },
        onError: (error, h) {
          _logError(error);
          h.next(error);
        },
      ),
    );
  }

  void _logRequest(RequestOptions options) {
    if (!kDebugMode) return;
    debugPrint('[API] ➜ ${options.method} ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('[API] query ${_safe(options.queryParameters)}');
    }
    if (options.data != null) debugPrint('[API] body ${_safe(options.data)}');
  }

  void _logResponse(Response<dynamic> response) {
    if (!kDebugMode) return;
    debugPrint(
      '[API] ✓ ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
    );
    if (response.data != null) {
      debugPrint('[API] response ${_safe(response.data)}');
    }
  }

  void _logError(DioException error) {
    if (!kDebugMode) return;
    debugPrint(
      '[API] ✗ ${error.response?.statusCode ?? error.type} ${error.requestOptions.method} ${error.requestOptions.uri}',
    );
    if (error.response?.data != null) {
      debugPrint('[API] error ${_safe(error.response?.data)}');
    }
  }

  dynamic _safe(dynamic value) {
    if (value is Map) {
      return value.map((key, item) {
        final name = key.toString().toLowerCase();
        final sensitive =
            name.contains('password') ||
            name.contains('token') ||
            name.contains('authorization') ||
            name.contains('secret') ||
            name.contains('credential');
        return MapEntry(key, sensitive ? '[REDACTED]' : _safe(item));
      });
    }
    if (value is Iterable) return value.map(_safe).toList();
    return value;
  }

  String message(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'];
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'Network unavailable. Check your connection.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
