import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisecure_app/app/core/constants/app_colors.dart';
import 'package:unisecure_app/app/core/constants/app_dimensions.dart';
import 'package:unisecure_app/app/core/constants/app_icons.dart';
import 'package:unisecure_app/app/core/constants/app_radius.dart';
import 'package:unisecure_app/app/core/constants/app_spacing.dart';
import 'package:unisecure_app/app/core/constants/app_strings.dart';
import 'package:unisecure_app/app/core/routes/not_found_view.dart';
import 'package:unisecure_app/app/core/theme/app_theme.dart';
import 'package:unisecure_app/app/core/widgets/widgets.dart';
import 'package:unisecure_app/core/api/api_client.dart';
import 'package:unisecure_app/core/auth/auth_controller.dart';
import 'package:unisecure_app/core/storage/secure_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  Get.testMode = true;

  group('Design Tokens & Theme Tests', () {
    test('AppColors provides non-null light mode palette', () {
      expect(AppColors.primary, const Color(0xFF3157D5));
      expect(AppColors.background, const Color(0xFFF6F8FC));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
      expect(AppColors.mainText, const Color(0xFF172033));
      expect(AppColors.border, const Color(0xFFE5EAF2));
      expect(AppColors.success, const Color(0xFF16845B));
      expect(AppColors.warning, const Color(0xFFB96A12));
      expect(AppColors.error, const Color(0xFFC83D4D));
      expect(AppColors.info, const Color(0xFF3574C8));
    });

    test('AppRadius and AppSpacing provide consistent metrics', () {
      expect(AppRadius.card, 18.0);
      expect(AppRadius.button, 14.0);
      expect(AppRadius.field, 14.0);
      expect(AppSpacing.xxs, 4.0);
      expect(AppSpacing.xl, 24.0);
      expect(AppDimensions.buttonHeight, 52.0);
      expect(AppDimensions.touchTargetMin, 48.0);
    });

    test('AppTheme creates a valid Material 3 Light Theme', () {
      final theme = AppTheme.light;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.surface, AppColors.surface);
    });

    test('statusColor correctly maps semantic states', () {
      expect(statusColor('present'), AppColors.success);
      expect(statusColor('active'), AppColors.success);
      expect(statusColor('late'), AppColors.warning);
      expect(statusColor('pending'), AppColors.warning);
      expect(statusColor('absent'), AppColors.error);
      expect(statusColor('cancelled'), AppColors.error);
      expect(statusColor('unknown'), AppColors.secondaryText);
    });
  });

  group('Core Reusable Widgets Tests', () {
    testWidgets('AppButton renders text and responds to taps', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton.primary(
              text: 'Save Changes',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Save Changes'), findsOneWidget);
      await tester.tap(find.text('Save Changes'));
      expect(tapped, isTrue);
    });

    testWidgets('AppButton displays loading spinner when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppButton.primary(text: 'Save', isLoading: true),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('AppTextField and AppPasswordField render properly', (
      tester,
    ) async {
      final textController = TextEditingController();
      final passwordController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  AppTextField(
                    controller: textController,
                    label: 'Email',
                    hint: 'Enter email',
                  ),
                  AppPasswordField(controller: passwordController),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    });

    testWidgets('AppSearchField renders with search icon and clears text', (
      tester,
    ) async {
      final searchController = TextEditingController(text: 'John');
      var cleared = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppSearchField(
              controller: searchController,
              onClear: () => cleared = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(AppIcons.search), findsOneWidget);
      expect(find.byIcon(AppIcons.close), findsOneWidget);
      await tester.tap(find.byIcon(AppIcons.close));
      await tester.pump();
      expect(searchController.text, isEmpty);
      expect(cleared, isTrue);
    });

    testWidgets('AppHeaders render titles and subtitles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: Column(
              children: [
                AppPageHeader(
                  title: 'Campus Gate Security',
                  subtitle: 'Live verification monitor',
                ),
                AppSectionHeader(
                  title: 'Today\'s Attendance',
                  actionLabel: 'View All',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Campus Gate Security'), findsOneWidget);
      expect(find.text('Live verification monitor'), findsOneWidget);
      expect(find.text('Today\'s Attendance'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets('AppCards and AppStatCard render metric values', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppStatCard(
              label: 'Attendance Rate',
              value: '94.2%',
              icon: Icons.pie_chart_outline,
            ),
          ),
        ),
      );

      expect(find.text('Attendance Rate'), findsOneWidget);
      expect(find.text('94.2%'), findsOneWidget);
    });

    testWidgets('AppStatusBadge displays semantic pill', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppStatusBadge(label: 'PRESENT', color: AppColors.success),
          ),
        ),
      );

      expect(find.text('PRESENT'), findsOneWidget);
    });

    testWidgets('AppEmptyState and AppErrorState render titles and messages', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Column(
              children: [
                const AppEmptyState(
                  title: 'No lectures scheduled',
                  message: 'Your timetable is empty for today.',
                ),
                AppErrorState(
                  title: 'Connection interrupted',
                  message: 'Check your network and retry.',
                  onRetry: () => retried = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('No lectures scheduled'), findsOneWidget);
      expect(find.text('Connection interrupted'), findsOneWidget);
      await tester.tap(find.text(AppStrings.retry));
      expect(retried, isTrue);
    });

    testWidgets('AppBottomNav renders all role navigation items', (
      tester,
    ) async {
      var selectedTab = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            bottomNavigationBar: AppBottomNav(
              currentIndex: 0,
              onTap: (index) => selectedTab = index,
              items: const [
                AppNavBarItem(
                  icon: AppIcons.home,
                  activeIcon: AppIcons.homeActive,
                  label: 'Home',
                ),
                AppNavBarItem(
                  icon: AppIcons.timetable,
                  activeIcon: AppIcons.timetableActive,
                  label: 'Timetable',
                ),
                AppNavBarItem(
                  icon: AppIcons.attendance,
                  activeIcon: AppIcons.attendanceActive,
                  label: 'Attendance',
                ),
                AppNavBarItem(
                  icon: AppIcons.more,
                  activeIcon: AppIcons.moreActive,
                  label: 'More',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Timetable'), findsOneWidget);
      expect(find.text('Attendance'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
      await tester.tap(find.text('Timetable'));
      expect(selectedTab, 1);
    });

    testWidgets('NotFoundView renders error message and button', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const NotFoundView()),
      );

      expect(find.text('Page Not Found'), findsOneWidget);
      expect(find.text('Go to Home'), findsOneWidget);
    });
  });

  group('Prototype Mock Authentication Tests', () {
    setUp(() {
      Get.reset();
      Get.testMode = true;
      Get.put(ApiClient(secureStore: SecureStore()));
    });

    tearDown(() {
      Get.reset();
      Get.testMode = true;
    });

    test('loginAsMock sets user for student role', () async {
      final auth = AuthController();
      Get.put(auth);

      await auth.loginAsMock('student');
      expect(auth.user.value?.role, 'student');
      expect(auth.user.value?.name, 'Faizan Khan');
      expect(auth.error.value, isEmpty);
    });

    test('loginAsMock sets user for teacher role', () async {
      final auth = AuthController();
      Get.put(auth);

      await auth.loginAsMock('teacher');
      expect(auth.user.value?.role, 'teacher');
      expect(auth.user.value?.name, 'Dr. Evelyn Reed');
    });

    test('loginAsMock sets user for guard role', () async {
      final auth = AuthController();
      Get.put(auth);

      await auth.loginAsMock('guard');
      expect(auth.user.value?.role, 'guard');
      expect(auth.user.value?.name, 'Officer Tariq Khan');
    });
  });
}
