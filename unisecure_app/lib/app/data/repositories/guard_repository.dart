import '../mock/guard_mock_data.dart';
import '../models/guard_models.dart';

/// In-memory repository managing Guard Desk security operations,
/// manual student auditing, transaction logging, and visitor management.
class GuardRepository {
  final bool simulateDelay;

  // In-memory mutable collections for realistic prototype simulation
  final List<GateTransaction> _transactions = [];
  final List<Visitor> _visitors = [];
  final List<StudentVerificationCard> _students = [];

  GuardRepository({this.simulateDelay = false}) {
    _initData();
  }

  void _initData() {
    _transactions.addAll(GuardMockData.initialTransactions);
    _visitors.addAll(GuardMockData.initialVisitors);
    _students.addAll(GuardMockData.verifiableStudents);
  }

  Future<void> _delay([int ms = 80]) async {
    if (simulateDelay) {
      await Future.delayed(Duration(milliseconds: ms));
    }
  }

  Future<GuardProfile> getProfile() async {
    await _delay();
    return GuardMockData.officerProfile;
  }

  Future<GateDeskSummary> getSummary() async {
    await _delay();
    final today = DateTime.now();
    final todayTransactions = _transactions.where((tx) {
      return tx.timestamp.year == today.year &&
          tx.timestamp.month == today.month &&
          tx.timestamp.day == today.day;
    }).toList();

    final entries = todayTransactions.where((tx) => tx.isEntry).length;
    final exits = todayTransactions.where((tx) => tx.isExit).length;
    final activeVisitors = _visitors.where((v) => v.isActive).length;

    return GateDeskSummary(
      assignedGate: GuardMockData.officerProfile.assignedGate,
      todayEntryCount: entries,
      todayExitCount: exits,
      activeVisitorsCount: activeVisitors,
      totalAuditedToday: todayTransactions.length,
    );
  }

  Future<List<GateTransaction>> getRecentTransactions({int limit = 10}) async {
    await _delay();
    final sorted = List.of(_transactions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }

  Future<List<GateTransaction>> getTransactions({
    String? eventTypeFilter,
    String? subjectFilter,
    String? query,
  }) async {
    await _delay();
    var list = List.of(_transactions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (eventTypeFilter != null &&
        eventTypeFilter.isNotEmpty &&
        eventTypeFilter.toLowerCase() != 'all') {
      list = list.where((tx) {
        return tx.eventType.toLowerCase() == eventTypeFilter.toLowerCase();
      }).toList();
    }

    if (subjectFilter != null &&
        subjectFilter.isNotEmpty &&
        subjectFilter.toLowerCase() != 'all') {
      list = list.where((tx) {
        return tx.subjectType.toLowerCase() == subjectFilter.toLowerCase();
      }).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      list = list.where((tx) {
        return tx.subjectName.toLowerCase().contains(q) ||
            tx.subjectIdentifier.toLowerCase().contains(q) ||
            tx.gate.toLowerCase().contains(q) ||
            (tx.notes?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return list;
  }

  Future<List<StudentVerificationCard>> searchStudents(String query) async {
    await _delay(100);
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase().trim();
    return _students.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.studentIdNumber.toLowerCase().contains(q) ||
          s.program.toLowerCase().contains(q);
    }).toList();
  }

  Future<StudentVerificationCard?> getStudentById(String idOrNumber) async {
    await _delay(50);
    final q = idOrNumber.toLowerCase().trim();
    try {
      return _students.firstWhere(
        (s) => s.id.toLowerCase() == q || s.studentIdNumber.toLowerCase() == q,
      );
    } catch (_) {
      return null;
    }
  }

  Future<GateTransaction> recordStudentTransaction({
    required String studentId,
    required String eventType, // 'entry' or 'exit'
    required String method, // 'face_scan' or 'manual_guard'
    String? notes,
  }) async {
    await _delay(120);
    final studentIndex = _students.indexWhere((s) => s.id == studentId);
    if (studentIndex == -1) {
      throw Exception('Student record not found for id: $studentId');
    }

    final student = _students[studentIndex];
    final tx = GateTransaction(
      id: 'tx-sim-${DateTime.now().millisecondsSinceEpoch}',
      eventType: eventType,
      subjectType: 'student',
      subjectId: student.id,
      subjectName: student.name,
      subjectIdentifier: student.studentIdNumber,
      departmentOrProgram: student.program,
      gate: 'Main Gate 1',
      timestamp: DateTime.now(),
      verificationMethod: method,
      status: student.isValid ? 'approved' : 'flagged',
      verifiedByGuardName: GuardMockData.officerProfile.name,
      notes: notes ?? 'Simulated $eventType recorded at Main Gate 1',
      isSimulated: true,
    );

    _transactions.insert(0, tx);

    // Update student's last transaction reference
    _students[studentIndex] = StudentVerificationCard(
      id: student.id,
      studentIdNumber: student.studentIdNumber,
      name: student.name,
      email: student.email,
      program: student.program,
      semester: student.semester,
      section: student.section,
      validityStatus: student.validityStatus,
      avatarUrl: student.avatarUrl,
      lastTransaction: tx,
    );

    return tx;
  }

  Future<List<Visitor>> getVisitors({
    String? statusFilter,
    String? query,
  }) async {
    await _delay();
    var list = List.of(_visitors)
      ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

    if (statusFilter != null &&
        statusFilter.isNotEmpty &&
        statusFilter.toLowerCase() != 'all') {
      list = list.where((v) {
        return v.status.toLowerCase() == statusFilter.toLowerCase();
      }).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      list = list.where((v) {
        return v.name.toLowerCase().contains(q) ||
            v.phone.toLowerCase().contains(q) ||
            v.badgeNumber.toLowerCase().contains(q) ||
            v.purpose.toLowerCase().contains(q) ||
            v.hostDepartmentOrPerson.toLowerCase().contains(q) ||
            (v.vehicleNumber?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return list;
  }

  Future<Visitor> registerVisitor({
    required String name,
    required String phone,
    required String purpose,
    required String hostDepartmentOrPerson,
    required String idProofType,
    required String idProofNumber,
    String? vehicleNumber,
  }) async {
    await _delay(120);
    final badgeNumber = 'VIS-${4000 + _visitors.length + 1}';
    final visitor = Visitor(
      id: 'vis-${DateTime.now().millisecondsSinceEpoch}',
      badgeNumber: badgeNumber,
      name: name,
      phone: phone,
      purpose: purpose,
      hostDepartmentOrPerson: hostDepartmentOrPerson,
      idProofType: idProofType,
      idProofNumber: idProofNumber,
      vehicleNumber: vehicleNumber,
      checkInTime: DateTime.now(),
      status: 'active',
      registeredByGate: 'Main Gate 1',
    );

    _visitors.insert(0, visitor);

    // Create an associated entry transaction in gate audit
    final tx = GateTransaction(
      id: 'tx-vis-${DateTime.now().millisecondsSinceEpoch}',
      eventType: 'entry',
      subjectType: 'visitor',
      subjectId: visitor.id,
      subjectName: visitor.name,
      subjectIdentifier: visitor.phone,
      departmentOrProgram: visitor.purpose,
      gate: 'Main Gate 1',
      timestamp: DateTime.now(),
      verificationMethod: 'visitor_pass',
      status: 'approved',
      verifiedByGuardName: GuardMockData.officerProfile.name,
      notes: 'Visitor Pass $badgeNumber issued. ID: $idProofType',
      isSimulated: true,
    );
    _transactions.insert(0, tx);

    return visitor;
  }

  Future<Visitor> checkOutVisitor(String visitorId) async {
    await _delay(100);
    final index = _visitors.indexWhere((v) => v.id == visitorId);
    if (index == -1) {
      throw Exception('Visitor record not found for id: $visitorId');
    }

    final current = _visitors[index];
    final updated = current.copyWith(
      status: 'checked_out',
      checkOutTime: DateTime.now(),
    );
    _visitors[index] = updated;

    // Create an associated exit transaction
    final tx = GateTransaction(
      id: 'tx-vis-out-${DateTime.now().millisecondsSinceEpoch}',
      eventType: 'exit',
      subjectType: 'visitor',
      subjectId: updated.id,
      subjectName: updated.name,
      subjectIdentifier: updated.phone,
      departmentOrProgram: updated.purpose,
      gate: 'Main Gate 1',
      timestamp: DateTime.now(),
      verificationMethod: 'visitor_pass',
      status: 'approved',
      verifiedByGuardName: GuardMockData.officerProfile.name,
      notes:
          'Visitor badge ${updated.badgeNumber} returned. Campus exit recorded.',
      isSimulated: true,
    );
    _transactions.insert(0, tx);

    return updated;
  }
}
