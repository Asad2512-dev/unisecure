import 'package:get/get.dart';
import '../../features/authentication/views/login_view.dart';
import '../../features/authentication/views/startup_view.dart';
import '../../features/guard/views/guard_shell.dart';
import '../../features/home/views/home_view.dart';
import '../../features/notifications/notification_view.dart';
import '../core/routes/app_routes.dart';
import '../core/routes/not_found_view.dart';
import '../modules/guard/views/guard_shell_view.dart';
import '../modules/guard/views/verification/guard_face_scan_view.dart';
import '../modules/guard/views/verification/guard_manual_verification_view.dart';
import '../modules/guard/views/visitors/guard_register_visitor_view.dart';
import '../modules/profile/views/shared_profile_view.dart';
import '../modules/student/views/courses/student_courses_view.dart';
import '../modules/student/views/profile/student_profile_view.dart';
import '../modules/student/views/security/student_campus_history_view.dart';
import '../modules/student/views/student_shell_view.dart';
import '../modules/teacher/views/teacher_shell_view.dart';

class AppPages {
  static const initial = AppRoutes.startup;

  static final unknownRoute = GetPage(
    name: AppRoutes.notFound,
    page: () => const NotFoundView(),
  );

  static final pages = [
    GetPage(
      name: AppRoutes.startup,
      page: () => const StartupView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      transition: Transition.fadeIn,
    ),
    // Student Workspace
    GetPage(
      name: AppRoutes.student,
      page: () => const StudentShellView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.studentCourses,
      page: () => const StudentCoursesView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.studentCampusHistory,
      page: () => const StudentCampusHistoryView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.studentProfile,
      page: () => const StudentProfileView(),
      transition: Transition.rightToLeft,
    ),
    // Teacher Workspace
    GetPage(
      name: AppRoutes.teacher,
      page: () => const TeacherShellView(),
      transition: Transition.rightToLeft,
    ),
    // Guard Workspace
    GetPage(
      name: AppRoutes.guard,
      page: () => const GuardShellView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.guardFaceScan,
      page: () => const GuardFaceScanView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.guardManual,
      page: () => const GuardManualVerificationView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.guardRegisterVisitor,
      page: () => const GuardRegisterVisitorView(),
      transition: Transition.rightToLeft,
    ),
    // Shared Modules
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const SharedProfileView(),
      transition: Transition.rightToLeft,
    ),
  ];
}
