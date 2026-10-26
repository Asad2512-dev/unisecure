// Data models for the UniSecure Guard Experience & Campus Access Control.

class GuardProfile {
  final int id;
  final String guardIdNumber;
  final String name;
  final String email;
  final String assignedGate;
  final String shift;
  final String status; // 'active', 'off_duty'
  final String phone;
  final String radioChannel;
  final String? profilePhoto;

  const GuardProfile({
    required this.id,
    required this.guardIdNumber,
    required this.name,
    required this.email,
    required this.assignedGate,
    required this.shift,
    required this.status,
    required this.phone,
    required this.radioChannel,
    this.profilePhoto,
  });

  bool get isActive => status.toLowerCase() == 'active';
}

class GateDeskSummary {
  final String assignedGate;
  final int todayEntryCount;
  final int todayExitCount;
  final int activeVisitorsCount;
  final int totalAuditedToday;

  const GateDeskSummary({
    required this.assignedGate,
    required this.todayEntryCount,
    required this.todayExitCount,
    required this.activeVisitorsCount,
    required this.totalAuditedToday,
  });
}

class GateTransaction {
  final String id;
  final String eventType; // 'entry', 'exit'
  final String subjectType; // 'student', 'visitor', 'staff'
  final String subjectId;
  final String subjectName;
  final String subjectIdentifier; // e.g. BSIT-MC-0001 or Phone
  final String departmentOrProgram;
  final String gate;
  final DateTime timestamp;
  final String
  verificationMethod; // 'face_scan', 'manual_guard', 'visitor_pass'
  final String status; // 'approved', 'flagged'
  final String verifiedByGuardName;
  final String? notes;
  final bool isSimulated;

  const GateTransaction({
    required this.id,
    required this.eventType,
    required this.subjectType,
    required this.subjectId,
    required this.subjectName,
    required this.subjectIdentifier,
    required this.departmentOrProgram,
    required this.gate,
    required this.timestamp,
    required this.verificationMethod,
    required this.status,
    required this.verifiedByGuardName,
    this.notes,
    this.isSimulated = true,
  });

  bool get isEntry => eventType.toLowerCase() == 'entry';
  bool get isExit => eventType.toLowerCase() == 'exit';
  bool get isStudent => subjectType.toLowerCase() == 'student';
  bool get isVisitor => subjectType.toLowerCase() == 'visitor';

  String get timeFormatted {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get dateFormatted {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year}';
  }

  String get methodDisplayName {
    switch (verificationMethod.toLowerCase()) {
      case 'face_scan':
        return 'Face Scan (Simulated)';
      case 'manual_guard':
        return 'Manual Guard Audit';
      case 'visitor_pass':
        return 'Visitor Pass';
      default:
        return verificationMethod;
    }
  }
}

class StudentVerificationCard {
  final String id;
  final String studentIdNumber;
  final String name;
  final String email;
  final String program;
  final int semester;
  final String section;
  final String validityStatus; // 'Active / Valid Student', 'Suspended', etc.
  final String? avatarUrl;
  final GateTransaction? lastTransaction;

  const StudentVerificationCard({
    required this.id,
    required this.studentIdNumber,
    required this.name,
    required this.email,
    required this.program,
    required this.semester,
    required this.section,
    required this.validityStatus,
    this.avatarUrl,
    this.lastTransaction,
  });

  bool get isValid =>
      validityStatus.toLowerCase().contains('active') ||
      validityStatus.toLowerCase().contains('valid');
}

class Visitor {
  final String id;
  final String badgeNumber;
  final String name;
  final String phone;
  final String purpose;
  final String hostDepartmentOrPerson;
  final String idProofType; // e.g. National ID, Driver License, Passport
  final String idProofNumber;
  final String? vehicleNumber;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status; // 'active', 'checked_out'
  final String registeredByGate;

  const Visitor({
    required this.id,
    required this.badgeNumber,
    required this.name,
    required this.phone,
    required this.purpose,
    required this.hostDepartmentOrPerson,
    required this.idProofType,
    required this.idProofNumber,
    this.vehicleNumber,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    required this.registeredByGate,
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get isCheckedOut => status.toLowerCase() == 'checked_out';

  String get checkInFormatted {
    final h = checkInTime.hour.toString().padLeft(2, '0');
    final m = checkInTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String? get checkOutFormatted {
    if (checkOutTime == null) return null;
    final h = checkOutTime!.hour.toString().padLeft(2, '0');
    final m = checkOutTime!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Visitor copyWith({String? status, DateTime? checkOutTime}) {
    return Visitor(
      id: id,
      badgeNumber: badgeNumber,
      name: name,
      phone: phone,
      purpose: purpose,
      hostDepartmentOrPerson: hostDepartmentOrPerson,
      idProofType: idProofType,
      idProofNumber: idProofNumber,
      vehicleNumber: vehicleNumber,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      registeredByGate: registeredByGate,
    );
  }
}
