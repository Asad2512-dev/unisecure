/// Reusable UI copy and string constants.
class AppStrings {
  AppStrings._();

  // Branding & General
  static const String appName = 'Uni Secure';
  static const String appTagline = 'Campus management, attendance & security';
  static const String welcomeBack = 'Welcome back';

  // Auth & Roles
  static const String loginTitle = 'Sign in to Uni Secure';
  static const String loginSubtitle =
      'Secure role-based access for students, teachers, and security staff.';
  static const String email = 'University email';
  static const String password = 'Password';
  static const String signIn = 'Sign in';
  static const String signingIn = 'Signing in...';
  static const String signOut = 'Sign out';
  static const String signOutConfirm = 'Are you sure you want to sign out?';
  static const String roleStudent = 'Student';
  static const String roleTeacher = 'Teacher';
  static const String roleGuard = 'Guard';
  static const String roleSelectPrompt = 'Quick Preview as:';
  static const String demoModeNote = 'Prototype Mode • In-memory state enabled';

  // Common Actions
  static const String retry = 'Try again';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String clear = 'Clear';
  static const String refresh = 'Refresh';
  static const String viewAll = 'View all';
  static const String close = 'Close';

  // States
  static const String emptyDefaultTitle = 'Nothing to show yet';
  static const String emptyDefaultMessage =
      'New records and updates will appear here.';
  static const String errorDefaultTitle = 'Unable to complete action';
  static const String errorDefaultMessage =
      'Something went wrong. Please try again.';
  static const String loading = 'Loading...';
}

/// Backward compatibility for existing references
class AppTexts {
  AppTexts._();
  static const String login = AppStrings.loginTitle;
  static const String retry = AppStrings.retry;
  static const String noData = AppStrings.emptyDefaultTitle;
}
