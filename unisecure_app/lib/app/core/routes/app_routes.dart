/// Centralized route names for GetX navigation.
class AppRoutes {
  AppRoutes._();

  static const String startup = '/startup';
  static const String login = '/login';
  static const String home = '/home';

  // Student routes
  static const String student = '/student';
  static const String studentCourses = '/student/courses';
  static const String studentCampusHistory = '/student/campus-history';
  static const String studentProfile = '/student/profile';

  // Teacher routes
  static const String teacher = '/teacher';
  static const String teacherCourses = '/teacher/courses';
  static const String teacherRoster = '/teacher/roster';

  // Guard routes
  static const String guard = '/guard';
  static const String guardFaceScan = '/guard/face-scan';
  static const String guardManual = '/guard/manual';
  static const String guardVisitors = '/guard/visitors';
  static const String guardRegisterVisitor = '/guard/register-visitor';

  // Shared routes
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String notFound = '/not-found';
}
