// Data models for the UniSecure Student Experience.

class StudentProfile {
  final int id;
  final String studentIdNumber;
  final String name;
  final String email;
  final String phone;
  final String program;
  final String department;
  final int semester;
  final String section;
  final double cgpa;
  final String advisorName;
  final int enrolledCredits;
  final double overallAttendancePercentage;
  final String status;
  final String? profilePhoto;

  const StudentProfile({
    required this.id,
    required this.studentIdNumber,
    required this.name,
    required this.email,
    required this.phone,
    required this.program,
    required this.department,
    required this.semester,
    required this.section,
    required this.cgpa,
    required this.advisorName,
    required this.enrolledCredits,
    required this.overallAttendancePercentage,
    required this.status,
    this.profilePhoto,
  });
}

class StudentCourse {
  final String id;
  final String code;
  final String title;
  final String description;
  final String instructorName;
  final String instructorEmail;
  final String section;
  final int credits;
  final String room;
  final String schedule;
  final int totalClasses;
  final int attendedClasses;
  final int lateClasses;
  final int absentClasses;

  const StudentCourse({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.instructorName,
    required this.instructorEmail,
    required this.section,
    required this.credits,
    required this.room,
    required this.schedule,
    required this.totalClasses,
    required this.attendedClasses,
    required this.lateClasses,
    required this.absentClasses,
  });

  double get attendancePercentage {
    if (totalClasses == 0) return 100.0;
    // Standard university formula: (present + 0.5 * late) / total
    final score = attendedClasses + (lateClasses * 0.5);
    return (score / totalClasses) * 100.0;
  }

  bool get isBelowThreshold => attendancePercentage < 75.0;
}

class TimetableSlot {
  final String id;
  final String courseCode;
  final String courseTitle;
  final String room;
  final String instructor;
  final int dayOfWeek; // 1 = Mon, 2 = Tue, ..., 6 = Sat
  final String startTime;
  final String endTime;
  final String type; // Lecture, Lab, Tutorial
  final bool isCurrent;
  final bool isNext;

  const TimetableSlot({
    required this.id,
    required this.courseCode,
    required this.courseTitle,
    required this.room,
    required this.instructor,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.isCurrent = false,
    this.isNext = false,
  });

  String get timeRange => '$startTime - $endTime';
}

class AttendanceRecord {
  final String id;
  final String courseCode;
  final String courseTitle;
  final DateTime sessionDate;
  final String sessionTime;
  final String room;
  final String teacher;
  final String status; // present, late, absent
  final String? remarks;

  const AttendanceRecord({
    required this.id,
    required this.courseCode,
    required this.courseTitle,
    required this.sessionDate,
    required this.sessionTime,
    required this.room,
    required this.teacher,
    required this.status,
    this.remarks,
  });
}

class AccessTransaction {
  final String id;
  final String eventType; // entry, exit
  final String gateName;
  final DateTime eventAt;
  final String
  verificationMethod; // Face Recognition, RFID Turnstile, NFC Sensor, Audited Manual
  final String status; // granted, denied
  final String? notes;

  const AccessTransaction({
    required this.id,
    required this.eventType,
    required this.gateName,
    required this.eventAt,
    required this.verificationMethod,
    required this.status,
    this.notes,
  });

  bool get isEntry => eventType.toLowerCase() == 'entry';
}

class CampusAlert {
  final String id;
  final String title;
  final String message;
  final String priority; // high, normal, info
  final DateTime timestamp;
  final bool isRead;

  const CampusAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.priority,
    required this.timestamp,
    this.isRead = false,
  });
}
