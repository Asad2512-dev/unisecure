import 'package:get/get.dart';
import '../../features/authentication/views/login_view.dart';
import '../../features/home/views/home_view.dart';

class AppPages {
  static const initial = '/login';
  static final pages = [
    GetPage(name: '/login', page: () => const LoginView()),
    GetPage(name: '/home', page: () => const HomeView()),
  ];
}
