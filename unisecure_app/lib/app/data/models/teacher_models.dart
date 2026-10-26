// Data models for the UniSecure Teacher Experience.

class TeacherProfile {
  final int id;
  final String teacherIdNumber;
  final String name;
  final String email;
  final String department;
  final String designation;
  final String officeRoom;
  final String officeHours;
  final int totalAssignedCourses;
  final int totalActiveStudents;
  final String? profilePhoto;

  const TeacherProfile({
    required this.id,
    required this.teacherIdNumber,
    required this.name,
    required this.email,
    required this.department,
    required this.designation,
    required this.officeRoom,
    required this.officeHours,
    required this.totalAssignedCourses,
    required this.totalActiveStudents,
    this.profilePhoto,
  });
}

class TeacherCourse {
  final String id;
  final String code;
  final String title;
  final String section;
  final int semester;
  final int credits;
  final String schedule;
  final String room;
  final int enrolledStudentCount;
  final String syllabus;

  const TeacherCourse({
    required this.id,
    required this.code,
    required this.title,
    required this.section,
    required this.semester,
    required this.credits,
    required this.schedule,
    required this.room,
    required this.enrolledStudentCount,
    required this.syllabus,
  });
}

class TeacherSession {
  final String id;
  final String courseId;
  final String courseCode;
  final String courseTitle;
  final String section;
  final String room;
  final DateTime sessionDate;
  final String startTime;
  final String endTime;
  final String status; // 'upcoming', 'open', 'finalized'
  final int totalStudents;
  final int presentCount;
  final int lateCount;
  final int absentCount;

  const TeacherSession({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseTitle,
    required this.section,
    required this.room,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalStudents,
    required this.presentCount,
    required this.lateCount,
    required this.absentCount,
  });

  bool get isOpen => status.toLowerCase() == 'open';
  bool get isUpcoming => status.toLowerCase() == 'upcoming';
  bool get isFinalized => status.toLowerCase() == 'finalized';

  int get unmarkedCount {
    final recorded = presentCount + lateCount + absentCount;
    return (totalStudents - recorded).clamp(0, totalStudents);
  }

  String get timeRange => '$startTime - $endTime';

  TeacherSession copyWith({
    String? status,
    int? presentCount,
    int? lateCount,
    int? absentCount,
  }) {
    return TeacherSession(
      id: id,
      courseId: courseId,
      courseCode: courseCode,
      courseTitle: courseTitle,
      section: section,
      room: room,
      sessionDate: sessionDate,
      startTime: startTime,
      endTime: endTime,
      status: status ?? this.status,
      totalStudents: totalStudents,
      presentCount: presentCount ?? this.presentCount,
      lateCount: lateCount ?? this.lateCount,
      absentCount: absentCount ?? this.absentCount,
    );
  }
}

class RosterStudent {
  final String id;
  final String studentIdNumber;
  final String name;
  final String email;
  final String? avatarUrl;
  final String attendanceStatus; // 'unmarked', 'present', 'late', 'absent'
  final DateTime? markedAt;
  final String? notes;

  const RosterStudent({
    required this.id,
    required this.studentIdNumber,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.attendanceStatus = 'unmarked',
    this.markedAt,
    this.notes,
  });

  bool get isUnmarked => attendanceStatus.toLowerCase() == 'unmarked';
  bool get isPresent => attendanceStatus.toLowerCase() == 'present';
  bool get isLate => attendanceStatus.toLowerCase() == 'late';
  bool get isAbsent => attendanceStatus.toLowerCase() == 'absent';

  RosterStudent copyWith({
    String? attendanceStatus,
    DateTime? markedAt,
    String? notes,
  }) {
    return RosterStudent(
      id: id,
      studentIdNumber: studentIdNumber,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      markedAt: markedAt ?? this.markedAt,
      notes: notes ?? this.notes,
    );
  }
}

class TeacherTimetableSlot {
  final String id;
  final String courseCode;
  final String courseTitle;
  final String section;
  final String room;
  final int dayOfWeek; // 1 = Mon, ..., 6 = Sat
  final String startTime;
  final String endTime;
  final String type; // Lecture, Lab, Seminar
  final bool isCurrent;
  final bool isNext;

  const TeacherTimetableSlot({
    required this.id,
    required this.courseCode,
    required this.courseTitle,
    required this.section,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.isCurrent = false,
    this.isNext = false,
  });

  String get timeRange => '$startTime - $endTime';
}
