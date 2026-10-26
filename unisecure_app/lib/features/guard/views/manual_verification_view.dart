import 'package:flutter/material.dart';
import '../../../app/data/models/guard_models.dart';
import '../../../app/modules/guard/views/verification/guard_manual_verification_view.dart';

export '../../../app/modules/guard/views/verification/guard_manual_verification_view.dart';

class ManualVerificationView extends StatelessWidget {
  final Map<String, dynamic> student;

  const ManualVerificationView({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final card = StudentVerificationCard(
      id: '${student['id'] ?? 'stu-001'}',
      studentIdNumber: '${student['student_id'] ?? 'BSIT-MC-0001'}',
      name: '${student['name'] ?? 'Faizan Khan'}',
      email: '${student['email'] ?? 'student@gmail.com'}',
      program: '${student['program'] ?? 'BS Information Technology'}',
      semester: student['semester'] is int ? student['semester'] as int : 4,
      section: '${student['section'] ?? 'Section MC'}',
      validityStatus: 'Active / Valid Student',
    );

    return GuardManualVerificationView(initialStudent: card);
  }
}
