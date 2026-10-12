import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/app_config.dart';
import 'theme/app_theme.dart';
import 'bindings/app_binding.dart';
import 'router/app_pages.dart';

class UniSecureApp extends StatelessWidget {
  const UniSecureApp({super.key});
  @override
  Widget build(BuildContext c) => GetMaterialApp(
    title: AppConfig.appName,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    initialBinding: AppBinding(),
    initialRoute: AppPages.initial,
    getPages: AppPages.pages,
  );
}
