class ApiEndpoints {
  static const login = '/auth/login',
      logout = '/auth/logout',
      me = '/me',
      notifications = '/notifications',
      readAll = '/notifications/read-all',
      deviceTokens = '/device-tokens';
  static const studentProfile = '/student/profile',
      studentAcademic = '/student/academic',
      studentCourses = '/student/courses',
      studentTimetable = '/student/timetable',
      studentAttendance = '/student/attendance',
      studentSummary = '/student/attendance/summary',
      studentSecurity = '/student/security/transactions';
  static const teacherProfile = '/teacher/profile',
      teacherCourses = '/teacher/courses',
      teacherSections = '/teacher/sections',
      teacherSessions = '/teacher/sessions',
      teacherSessionStudents = '/teacher/sessions/{id}/students',
      teacherSessionAttendance = '/teacher/sessions/{id}/attendance',
      teacherMarkAttendance = '/teacher/sessions/{id}/attendance',
      teacherFinalize = '/teacher/sessions/{id}/finalize';
  static const guardProfile = '/guard/profile',
      guardGate = '/guard/gate',
      guardSearch = '/guard/students/search',
      guardManual = '/guard/security/manual',
      guardFace = '/guard/security/face',
      guardTransactions = '/guard/security/transactions',
      guardVisitors = '/guard/visitors';

  static String teacherSession(String template, dynamic id) =>
      template.replaceFirst('{id}', '$id');
}
