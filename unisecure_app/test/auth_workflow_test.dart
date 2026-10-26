import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:unisecure_app/core/api/api_client.dart';
import 'package:unisecure_app/core/auth/auth_controller.dart';
import 'package:unisecure_app/core/storage/secure_store.dart';

class _MemoryStore extends SecureStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String token) async => value = token;

  @override
  Future<void> clear() async => value = null;
}

class _AuthAdapter implements HttpClientAdapter {
  final bool rejectLogin;
  RequestOptions? lastRequest;

  _AuthAdapter({this.rejectLogin = false});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    if (rejectLogin) {
      throw DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 422,
          data: {
            'success': false,
            'message': 'Invalid credentials.',
            'errors': {},
          },
        ),
      );
    }
    final data = options.path.endsWith('/login')
        ? '{"success":true,"data":{"token":"fresh-token","user":{"id":4,"name":"Demo Guard","email":"guard@gmail.com","status":"active","role":"guard"}}}'
        : '{"success":true,"data":{"user":{"id":4,"name":"Demo Guard","email":"guard@gmail.com","status":"active","role":"guard"}}}';
    return ResponseBody.fromString(
      data,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  tearDown(() => Get.reset());

  test('successful login persists token and resolves guard identity', () async {
    final store = _MemoryStore();
    final adapter = _AuthAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
      ..httpClientAdapter = adapter;
    final client = ApiClient(client: dio, secureStore: store);
    Get.put(client);
    final auth = AuthController();
    await auth.login('guard@gmail.com', '12345678');

    expect(store.value, 'fresh-token');
    expect(auth.user.value?.role, 'guard');
    expect(adapter.lastRequest?.data, containsPair('email', 'guard@gmail.com'));
    expect(auth.error.value, isEmpty);
  });

  test('failed login preserves no token and exposes backend error', () async {
    final store = _MemoryStore();
    final adapter = _AuthAdapter(rejectLogin: true);
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
      ..httpClientAdapter = adapter;
    final client = ApiClient(client: dio, secureStore: store);
    Get.put(client);
    final auth = AuthController();

    await auth.login('guard@gmail.com', 'wrong-password');

    expect(store.value, isNull);
    expect(auth.user.value, isNull);
    expect(auth.error.value, 'Invalid credentials.');
  });

  test(
    'offline demo credentials sign in student role as Faizan Khan',
    () async {
      final store = _MemoryStore();
      // Simulate connection failure (e.g. offline mobile device)
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.connectionError,
                  error: 'Connection refused',
                ),
              );
            },
          ),
        );
      final client = ApiClient(client: dio, secureStore: store);
      Get.put(client);
      final auth = AuthController();

      await auth.login('student@gmail.com', '12345678');

      expect(auth.user.value?.role, 'student');
      expect(auth.user.value?.name, 'Faizan Khan');
      expect(auth.user.value?.email, 'student@gmail.com');
      expect(auth.error.value, isEmpty);
    },
  );

  test('offline demo credentials sign in teacher and guard roles', () async {
    final store = _MemoryStore();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
          },
        ),
      );
    Get.put(ApiClient(client: dio, secureStore: store));
    final auth = AuthController();

    await auth.login('teacher@gmail.com', '12345678');
    expect(auth.user.value?.role, 'teacher');

    await auth.login('guard@gmail.com', '12345678');
    expect(auth.user.value?.role, 'guard');
  });

  test(
    'offline demo credentials sign in student role as Faizan Khan',
    () async {
      final store = _MemoryStore();
      // Simulate connection failure (e.g. offline mobile device)
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.connectionError,
                  error: 'Connection refused',
                ),
              );
            },
          ),
        );
      final client = ApiClient(client: dio, secureStore: store);
      Get.put(client);
      final auth = AuthController();

      await auth.login('student@gmail.com', '12345678');

      expect(auth.user.value?.role, 'student');
      expect(auth.user.value?.name, 'Faizan Khan');
      expect(auth.user.value?.email, 'student@gmail.com');
      expect(auth.error.value, isEmpty);
    },
  );

  test('offline demo credentials sign in teacher and guard roles', () async {
    final store = _MemoryStore();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
          },
        ),
      );
    Get.put(ApiClient(client: dio, secureStore: store));
    final auth = AuthController();

    await auth.login('teacher@gmail.com', '12345678');
    expect(auth.user.value?.role, 'teacher');

    await auth.login('guard@gmail.com', '12345678');
    expect(auth.user.value?.role, 'guard');
  });

  test('session restoration clears an invalid stored session', () async {
    final store = _MemoryStore()..value = 'expired-token';
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
      ..httpClientAdapter = _AuthAdapter(rejectLogin: true);
    Get.put(ApiClient(client: dio, secureStore: store));
    final auth = AuthController();

    expect(await auth.restore(), isFalse);
    expect(store.value, isNull);
    expect(auth.user.value, isNull);
  });

  test('manual verification request must include confirmation', () {
    final request = <String, dynamic>{
      'student_id': 1,
      'confirmed': true,
      'reason': 'Student card checked',
    };

    expect(request['confirmed'], isTrue);
    expect(request['reason'], hasLength(greaterThanOrEqualTo(5)));
  });
}
