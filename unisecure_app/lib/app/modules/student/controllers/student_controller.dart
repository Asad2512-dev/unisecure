import 'package:get/get.dart';
import '../../../data/models/student_models.dart';
import '../../../data/repositories/student_repository.dart';

/// GetX controller for the entire Student Workspace.
class StudentController extends GetxController {
  final StudentRepository repository;

  StudentController({StudentRepository? repo})
    : repository = repo ?? StudentRepository();

  // Navigation tab state (0: Home, 1: Timetable, 2: Attendance, 3: More)
  final currentTabIndex = 0.obs;

  // Loading states
  final isLoading = true.obs;
  final isRefreshing = false.obs;

  // Data Observables
  final profile = Rxn<StudentProfile>();
  final courses = <StudentCourse>[].obs;
  final timetable = <TimetableSlot>[].obs;
  final attendanceRecords = <AttendanceRecord>[].obs;
  final accessHistory = <AccessTransaction>[].obs;
  final alerts = <CampusAlert>[].obs;

  // Filters & Selection
  // 1 = Mon, 2 = Tue, 3 = Wed, 4 = Thu, 5 = Fri, 6 = Sat
  final selectedDayOfWeek = 1.obs;
  final selectedAttendanceFilter = 'All'.obs;
  final selectedAccessFilter = 'All'.obs;
  final courseSearchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initDay();
    loadAll();
  }

  void _initDay() {
    final weekday = DateTime.now().weekday;
    // Map Sunday (7) to Monday (1), otherwise clamp between 1 and 6
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
        repository.getTimetable(),
        repository.getAttendance(),
        repository.getAccessTransactions(),
        repository.getCampusAlerts(),
      ]);

      profile.value = results[0] as StudentProfile;
      courses.assignAll(results[1] as List<StudentCourse>);
      timetable.assignAll(results[2] as List<TimetableSlot>);
      attendanceRecords.assignAll(results[3] as List<AttendanceRecord>);
      accessHistory.assignAll(results[4] as List<AccessTransaction>);
      alerts.assignAll(results[5] as List<CampusAlert>);
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> refreshData() async {
    isRefreshing.value = true;
    await loadAll(showSpinner: false);
  }

  // Timetable helpers
  void selectDay(int day) {
    selectedDayOfWeek.value = day;
  }

  List<TimetableSlot> get slotsForSelectedDay {
    return timetable
        .where((s) => s.dayOfWeek == selectedDayOfWeek.value)
        .toList();
  }

  TimetableSlot? get nextClass {
    final todaySlots = timetable
        .where((s) => s.dayOfWeek == selectedDayOfWeek.value)
        .toList();
    if (todaySlots.isEmpty) return null;
    return todaySlots.firstWhere(
      (s) => s.isNext,
      orElse: () => todaySlots.first,
    );
  }

  List<TimetableSlot> get todayClasses {
    return timetable
        .where((s) => s.dayOfWeek == selectedDayOfWeek.value)
        .toList();
  }

  // Attendance helpers
  void filterAttendance(String status) {
    selectedAttendanceFilter.value = status;
  }

  List<AttendanceRecord> get filteredAttendanceRecords {
    if (selectedAttendanceFilter.value == 'All') {
      return attendanceRecords;
    }
    return attendanceRecords
        .where(
          (r) =>
              r.status.toLowerCase() ==
              selectedAttendanceFilter.value.toLowerCase(),
        )
        .toList();
  }

  int get totalPresentCount =>
      courses.fold(0, (sum, c) => sum + c.attendedClasses);

  int get totalLateCount => courses.fold(0, (sum, c) => sum + c.lateClasses);

  int get totalAbsentCount =>
      courses.fold(0, (sum, c) => sum + c.absentClasses);

  int get totalLecturesCount =>
      courses.fold(0, (sum, c) => sum + c.totalClasses);

  double get overallAttendanceRate {
    if (totalLecturesCount == 0) return 100.0;
    final score = totalPresentCount + (totalLateCount * 0.5);
    return (score / totalLecturesCount) * 100.0;
  }

  // Course helpers
  void searchCourses(String query) {
    courseSearchQuery.value = query;
  }

  List<StudentCourse> get filteredCourses {
    if (courseSearchQuery.value.trim().isEmpty) {
      return courses;
    }
    final q = courseSearchQuery.value.toLowerCase();
    return courses.where((c) {
      return c.code.toLowerCase().contains(q) ||
          c.title.toLowerCase().contains(q) ||
          c.instructorName.toLowerCase().contains(q);
    }).toList();
  }

  // Access history helpers
  void filterAccess(String filter) {
    selectedAccessFilter.value = filter;
  }

  List<AccessTransaction> get filteredAccessHistory {
    if (selectedAccessFilter.value == 'All') {
      return accessHistory;
    }
    return accessHistory
        .where(
          (tx) =>
              tx.eventType.toLowerCase() ==
              selectedAccessFilter.value.toLowerCase(),
        )
        .toList();
  }
}
