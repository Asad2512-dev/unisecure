import 'package:get/get.dart';
import '../../app/config/api_endpoints.dart';
import '../../app/router/app_pages.dart';
import '../api/api_client.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final api = Get.find<ApiClient>();
  final user = Rxn<UserModel>();
  final loading = false.obs;
  final error = ''.obs;
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

  Future<void> login(String email, String password) async {
    loading.value = true;
    error.value = '';
    try {
      final r = await api.dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      await api.store.write(r.data['data']['token']);
      user.value = UserModel.fromJson(r.data['data']['user']);
      Get.offAllNamed('/home');
    } catch (e) {
      error.value = api.message(e);
    } finally {
      loading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await api.dio.post(ApiEndpoints.logout);
    } catch (_) {}
    await api.store.clear();
    user.value = null;
    Get.offAllNamed(AppPages.initial);
  }
}
