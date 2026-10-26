import 'package:get/get.dart';
import '../../../data/models/teacher_models.dart';
import '../../../data/repositories/teacher_repository.dart';

/// GetX controller managing the general Teacher Workspace state.
class TeacherController extends GetxController {
  final TeacherRepository repository;

  TeacherController({TeacherRepository? repo})
    : repository = repo ?? TeacherRepository();

  // Navigation tab state (0: Home, 1: Sessions, 2: Timetable, 3: Courses)
  final currentTabIndex = 0.obs;

  // Loading states
  final isLoading = true.obs;
  final isRefreshing = false.obs;

  // Data Observables
  final profile = Rxn<TeacherProfile>();
  final courses = <TeacherCourse>[].obs;
  final sessions = <TeacherSession>[].obs;
  final timetable = <TeacherTimetableSlot>[].obs;

  // Filters
  final selectedDayOfWeek = 1.obs;
  final selectedSessionFilter = 'All'.obs; // All, Open, Upcoming, Finalized
  final courseSearchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initDay();
    loadAll();
  }

  void _initDay() {
    final weekday = DateTime.now().weekday;
    if (weekday >= 1 && weekday <= 6) {
      selectedDayOfWeek.value = weekday;
    } else {
      selectedDayOfWeek.value = 1;
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  Future<void> loadAll({bool showSpinner = true}) async {
    if (showSpinner) isLoading.value = true;
    try {
      final results = await Future.wait([
        repository.getProfile(),
        repository.getCourses(),
        repository.getSessions(),
        repository.getTimetable(),
      ]);

      profile.value = results[0] as TeacherProfile;
      courses.assignAll(results[1] as List<TeacherCourse>);
      sessions.assignAll(results[2] as List<TeacherSession>);
      timetable.assignAll(results[3] as List<TeacherTimetableSlot>);
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> refreshData() async {
    isRefreshing.value = true;
    await loadAll(showSpinner: false);
  }

  // Session helpers & computed states
  void filterSessions(String filter) {
    selectedSessionFilter.value = filter;
  }

  List<TeacherSession> get filteredSessions {
    if (selectedSessionFilter.value == 'All') {
      return sessions;
    }
    return sessions
        .where(
          (s) =>
              s.status.toLowerCase() ==
              selectedSessionFilter.value.toLowerCase(),
        )
        .toList();
  }

  List<TeacherSession> get todaySessions {
    final now = DateTime.now();
    return sessions.where((s) {
      return s.sessionDate.year == now.year &&
          s.sessionDate.month == now.month &&
          s.sessionDate.day == now.day;
    }).toList();
  }

  TeacherSession? get activeSessionToMark {
    try {
      return sessions.firstWhere((s) => s.isOpen);
    } catch (_) {
      return null;
    }
  }

  TeacherSession? get nextScheduledClass {
    try {
      return sessions.firstWhere((s) => s.isUpcoming);
    } catch (_) {
      return null;
    }
  }

  List<TeacherSession> get recentlyCompletedSessions {
    return sessions.where((s) => s.isFinalized).toList();
  }

  // Timetable helpers
  void selectDay(int day) {
    selectedDayOfWeek.value = day;
  }

  List<TeacherTimetableSlot> get slotsForSelectedDay {
    return timetable
        .where((s) => s.dayOfWeek == selectedDayOfWeek.value)
        .toList();
  }

  // Course helpers
  void searchCourses(String q) {
    courseSearchQuery.value = q;
  }

  List<TeacherCourse> get filteredCourses {
    if (courseSearchQuery.value.trim().isEmpty) return courses;
    final q = courseSearchQuery.value.toLowerCase();
    return courses.where((c) {
      return c.code.toLowerCase().contains(q) ||
          c.title.toLowerCase().contains(q) ||
          c.section.toLowerCase().contains(q);
    }).toList();
  }
}
