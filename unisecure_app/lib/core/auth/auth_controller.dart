import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../app/config/api_endpoints.dart';
import '../../app/core/routes/app_routes.dart';
import '../api/api_client.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final api = Get.find<ApiClient>();
  final user = Rxn<UserModel>();
  final loading = false.obs;
  final error = ''.obs;

  /// Restores existing session from local storage or mock state.
  Future<bool> restore() async {
    final token = await api.store.read();
    if (token == null) return false;
    try {
      final r = await api.dio.get(ApiEndpoints.me);
      user.value = UserModel.fromJson(r.data['data']['user']);
      return true;
    } catch (_) {
      await api.store.clear();
      return false;
    }
  }

  /// Authenticates using the real backend API, or local credentials for demo accounts.
  Future<void> login(String email, String password) async {
    loading.value = true;
    error.value = '';
    final trimmedEmail = email.trim().toLowerCase();

    try {
      final r = await api.dio.post(
        ApiEndpoints.login,
        data: {'email': email.trim(), 'password': password},
      );
      await api.store.write(r.data['data']['token']);
      user.value = UserModel.fromJson(r.data['data']['user']);
      routeForRole();
    } catch (e) {
      // If server is unreachable or offline, verify against demo credentials
      final isConnectionIssue =
          e is DioException &&
          (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError ||
              e.response == null);

      if (isConnectionIssue && password == '12345678') {
        if (trimmedEmail == 'student@gmail.com') {
          user.value = const UserModel(
            id: 101,
            name: 'Faizan Khan',
            email: 'student@gmail.com',
            role: 'student',
          );
          routeForRole();
          return;
        } else if (trimmedEmail == 'teacher@gmail.com') {
          user.value = const UserModel(
            id: 202,
            name: 'Dr. Evelyn Reed',
            email: 'teacher@gmail.com',
            role: 'teacher',
          );
          routeForRole();
          return;
        } else if (trimmedEmail == 'guard@gmail.com') {
          user.value = const UserModel(
            id: 303,
            name: 'Officer Tariq Khan',
            email: 'guard@gmail.com',
            role: 'guard',
          );
          routeForRole();
          return;
        }
      }
      error.value = api.message(e);
    } finally {
      loading.value = false;
    }
  }

  /// Prototype mode: simulated role sign-in without server connection.
  Future<void> loginAsMock(String role) async {
    loading.value = true;
    error.value = '';
    // Brief realistic prototype transition
    await Future.delayed(const Duration(milliseconds: 200));

    switch (role.toLowerCase()) {
      case 'student':
        user.value = const UserModel(
          id: 101,
          name: 'Faizan Khan',
          email: 'student@gmail.com',
          role: 'student',
        );
      case 'teacher':
        user.value = const UserModel(
          id: 202,
          name: 'Dr. Evelyn Reed',
          email: 'teacher@gmail.com',
          role: 'teacher',
        );
      case 'guard':
        user.value = const UserModel(
          id: 303,
          name: 'Officer Tariq Khan',
          email: 'guard@gmail.com',
          role: 'guard',
        );
      default:
        error.value = 'Unknown preview role requested.';
        loading.value = false;
        return;
    }

    loading.value = false;
    routeForRole();
  }

  /// Routes to the dedicated workspace shell for the authenticated role.
  void routeForRole() {
    try {
      switch (user.value?.role) {
        case 'student':
          Get.offAllNamed(AppRoutes.student);
        case 'teacher':
          Get.offAllNamed(AppRoutes.teacher);
        case 'guard':
          Get.offAllNamed(AppRoutes.guard);
        case 'admin':
          error.value = 'Administrator access uses the web panel.';
        default:
          error.value = 'This account has no supported mobile role.';
      }
    } catch (_) {
      // Standalone unit tests run without Get.key or GetMaterialApp context.
    }
  }

  /// Terminates active session and resets state.
  Future<void> logout() async {
    try {
      await api.dio.post(ApiEndpoints.logout);
    } catch (_) {}
    await api.store.clear();
    user.value = null;
    Get.offAllNamed(AppRoutes.startup);
  }
}
