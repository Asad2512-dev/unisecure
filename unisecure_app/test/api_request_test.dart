import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisecure_app/core/api/api_client.dart';
import 'package:unisecure_app/core/storage/secure_store.dart';
import 'dart:typed_data';

class _FakeAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;
  final int statusCode;
  _FakeAdapter({this.statusCode = 200});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    if (statusCode >= 400) {
      throw DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: statusCode,
          data: {
            'success': false,
            'message': 'Request rejected.',
            'errors': {},
          },
        ),
      );
    }
    return ResponseBody.fromString(
      '{"success":true,"message":"ok","data":{"items":[]},"meta":{}}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _MemoryStore extends SecureStore {
  @override
  Future<String?> read() async => 'test-token';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('API client preserves the versioned request contract', () async {
    final adapter = _FakeAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
      ..httpClientAdapter = adapter;
    final client = ApiClient(client: dio, secureStore: _MemoryStore());
    final response = await client.dio.get('/notifications');
    expect(response.data['success'], isTrue);
    expect(adapter.lastRequest?.path, '/notifications');
    expect(adapter.lastRequest?.headers['Authorization'], 'Bearer test-token');
  });

  test(
    'API client exposes rejected request envelopes without success',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
        ..httpClientAdapter = _FakeAdapter(statusCode: 403);
      final client = ApiClient(client: dio, secureStore: _MemoryStore());
      expect(
        () => client.dio.get('/teacher/sessions'),
        throwsA(isA<DioException>()),
      );
    },
  );
}
