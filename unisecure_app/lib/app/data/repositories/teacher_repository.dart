import '../mock/teacher_mock_data.dart';
import '../models/teacher_models.dart';

/// Repository handling Teacher profile, courses, sessions, timetable, and attendance rosters.
class TeacherRepository {
  final bool simulateDelay;

  // In-memory mutable collections for realistic prototype simulation
  final List<TeacherSession> _sessions = [];
  final Map<String, List<RosterStudent>> _sessionRosters = {};

  TeacherRepository({this.simulateDelay = false}) {
    _initData();
  }

  void _initData() {
    _sessions.addAll(TeacherMockData.initialSessions);
    for (final s in _sessions) {
      // Clone default roster for each session
      _sessionRosters[s.id] = TeacherMockData.defaultRoster
          .map(
            (student) => student.copyWith(
              attendanceStatus: s.isFinalized
                  ? (student.id == 'st-5'
                        ? 'absent'
                        : (student.id == 'st-3' ? 'late' : 'present'))
                  : 'unmarked',
            ),
          )
          .toList();
    }
  }

  Future<void> _delay([int ms = 80]) async {
    if (simulateDelay) {
      await Future.delayed(Duration(milliseconds: ms));
    }
  }

  Future<TeacherProfile> getProfile() async {
    await _delay();
    return TeacherMockData.profile;
  }

  Future<List<TeacherCourse>> getCourses({String? query}) async {
    await _delay();
    final list = TeacherMockData.courses;
    if (query == null || query.trim().isEmpty) return list;
    final q = query.toLowerCase();
    return list.where((c) {
      return c.code.toLowerCase().contains(q) ||
          c.title.toLowerCase().contains(q) ||
          c.section.toLowerCase().contains(q);
    }).toList();
  }

  Future<TeacherCourse?> getCourseById(String id) async {
    await _delay(40);
    try {
      return TeacherMockData.courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<TeacherSession>> getSessions({String? statusFilter}) async {
    await _delay();
    if (statusFilter == null || statusFilter.toLowerCase() == 'all') {
      return List.unmodifiable(_sessions);
    }
    return _sessions
        .where((s) => s.status.toLowerCase() == statusFilter.toLowerCase())
        .toList();
  }

  Future<TeacherSession?> getSessionById(String sessionId) async {
    await _delay(40);
    try {
      return _sessions.firstWhere((s) => s.id == sessionId);
    } catch (_) {
      return null;
    }
  }

  Future<List<RosterStudent>> getSessionRoster(String sessionId) async {
    await _delay();
    if (!_sessionRosters.containsKey(sessionId)) {
      _sessionRosters[sessionId] = TeacherMockData.defaultRoster
          .map((s) => s.copyWith(attendanceStatus: 'unmarked'))
          .toList();
    }
    return List.of(_sessionRosters[sessionId]!);
  }

  Future<void> saveRosterDraft(
    String sessionId,
    List<RosterStudent> roster,
  ) async {
    await _delay(60);
    _sessionRosters[sessionId] = List.of(roster);

    final present = roster.where((s) => s.isPresent).length;
    final late = roster.where((s) => s.isLate).length;
    final absent = roster.where((s) => s.isAbsent).length;

    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _sessions[index] = _sessions[index].copyWith(
        presentCount: present,
        lateCount: late,
        absentCount: absent,
      );
    }
  }

  Future<TeacherSession> finalizeSession(
    String sessionId,
    List<RosterStudent> roster,
  ) async {
    await _delay(100);
    // When finalization occurs, any unmarked student is automatically assigned 'absent'
    final finalizedRoster = roster.map((s) {
      if (s.isUnmarked) {
        return s.copyWith(
          attendanceStatus: 'absent',
          notes: 'Auto-marked absent on session finalization',
        );
      }
      return s;
    }).toList();

    _sessionRosters[sessionId] = finalizedRoster;

    final present = finalizedRoster.where((s) => s.isPresent).length;
    final late = finalizedRoster.where((s) => s.isLate).length;
    final absent = finalizedRoster.where((s) => s.isAbsent).length;

    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final updated = _sessions[index].copyWith(
        status: 'finalized',
        presentCount: present,
        lateCount: late,
        absentCount: absent,
      );
      _sessions[index] = updated;
      return updated;
    }
    throw Exception('Session $sessionId not found');
  }

  Future<List<TeacherTimetableSlot>> getTimetable({int? dayOfWeek}) async {
    await _delay();
    final list = TeacherMockData.timetable;
    if (dayOfWeek == null) return list;
    return list.where((s) => s.dayOfWeek == dayOfWeek).toList();
  }
}
