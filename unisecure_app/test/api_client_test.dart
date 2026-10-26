import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisecure_app/core/api/api_client.dart';

void main() {
  test('normalizes Laravel error envelopes', () {
    final client = ApiClient();
    final error = DioException(
      requestOptions: RequestOptions(path: '/test'),
      response: Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 422,
        data: {'success': false, 'message': 'Validation failed.', 'errors': {}},
      ),
    );
    expect(client.message(error), 'Validation failed.');
  });

  test('returns a safe message for network failures', () {
    final client = ApiClient();
    final error = DioException(
      requestOptions: RequestOptions(path: '/test'),
      type: DioExceptionType.connectionError,
    );
    expect(
      client.message(error),
      'Network unavailable. Check your connection.',
    );
  });

  test('preserves authorization and server error messages', () {
    final client = ApiClient();
    for (final message in ['Not authorized.', 'Server unavailable.']) {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: message.startsWith('Not') ? 403 : 500,
          data: {'success': false, 'message': message, 'errors': {}},
        ),
      );
      expect(client.message(error), message);
    }
  });
}
