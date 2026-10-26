import '../mock/student_mock_data.dart';
import '../models/student_models.dart';

/// Repository interface and in-memory mock implementation for Student data.
class StudentRepository {
  final bool simulateDelay;

  StudentRepository({this.simulateDelay = false});

  Future<void> _delay([int ms = 80]) async {
    if (simulateDelay) {
      await Future.delayed(Duration(milliseconds: ms));
    }
  }

  Future<StudentProfile> getProfile() async {
    await _delay();
    return StudentMockData.profile;
  }

  Future<List<StudentCourse>> getCourses({String? query}) async {
    await _delay();
    final list = StudentMockData.courses;
    if (query == null || query.trim().isEmpty) return list;
    final q = query.toLowerCase();
    return list.where((c) {
      return c.code.toLowerCase().contains(q) ||
          c.title.toLowerCase().contains(q) ||
          c.instructorName.toLowerCase().contains(q);
    }).toList();
  }

  Future<StudentCourse?> getCourseById(String id) async {
    await _delay(40);
    try {
      return StudentMockData.courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<TimetableSlot>> getTimetable({int? dayOfWeek}) async {
    await _delay();
    final list = StudentMockData.timetable;
    if (dayOfWeek == null) return list;
    return list.where((s) => s.dayOfWeek == dayOfWeek).toList();
  }

  Future<List<AttendanceRecord>> getAttendance({
    String? statusFilter,
    String? courseCode,
  }) async {
    await _delay();
    var list = StudentMockData.attendanceRecords;
    if (statusFilter != null && statusFilter.toLowerCase() != 'all') {
      list = list
          .where((a) => a.status.toLowerCase() == statusFilter.toLowerCase())
          .toList();
    }
    if (courseCode != null && courseCode.trim().isNotEmpty) {
      list = list
          .where((a) => a.courseCode.toLowerCase() == courseCode.toLowerCase())
          .toList();
    }
    return list;
  }

  Future<List<AccessTransaction>> getAccessTransactions({
    String? filter,
  }) async {
    await _delay();
    final list = StudentMockData.accessHistory;
    if (filter == null || filter.toLowerCase() == 'all') return list;
    return list
        .where((tx) => tx.eventType.toLowerCase() == filter.toLowerCase())
        .toList();
  }

  Future<List<CampusAlert>> getCampusAlerts() async {
    await _delay();
    return StudentMockData.campusAlerts;
  }
}
