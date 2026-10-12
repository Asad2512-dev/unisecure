import 'package:dio/dio.dart';
import '../../app/config/app_config.dart';
import '../storage/secure_store.dart';

class ApiClient {
  final store = SecureStore();
  late final Dio dio;
  ApiClient() {
    dio = Dio(
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
          h.next(o);
        },
      ),
    );
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
