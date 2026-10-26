import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/config/api_endpoints.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/api/api_client.dart';
import '../../../core/widgets/app_ui.dart';

class TeacherSessionView extends StatefulWidget {
  final Map<String, dynamic> session;
  const TeacherSessionView({super.key, required this.session});
  @override
  State<TeacherSessionView> createState() => _TeacherSessionViewState();
}

class _TeacherSessionViewState extends State<TeacherSessionView> {
  final api = Get.find<ApiClient>();
  bool loading = true, submitting = false;
  String? error;
  List<Map<String, dynamic>> students = [];
  Map<String, dynamic> attendanceSummary = {};
  String get id => '${widget.session['id']}';

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final responses = await Future.wait([
        api.dio.get(
          ApiEndpoints.teacherSession(ApiEndpoints.teacherSessionStudents, id),
        ),
        api.dio.get(
          ApiEndpoints.teacherSession(
            ApiEndpoints.teacherSessionAttendance,
            id,
          ),
        ),
      ]);
      final data = responses[0].data['data'];
      final items = data is Map ? data['items'] : null;
      students = items is List
          ? items
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : [];
      final attendanceData = responses[1].data['data'];
      if (attendanceData is Map) {
        attendanceSummary = Map<String, dynamic>.from(
          attendanceData['summary'] is Map ? attendanceData['summary'] : {},
        );
      }
      error = null;
    } catch (exception) {
      error = api.message(exception);
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> mark(Map<String, dynamic> student) async {
    if (submitting) return;
    setState(() => submitting = true);
    try {
      await api.dio.post(
        ApiEndpoints.teacherSession(ApiEndpoints.teacherMarkAttendance, id),
        data: {'student_id': student['id']},
      );
      await load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance recorded by the server.')),
        );
      }
    } catch (exception) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(api.message(exception))));
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  Future<void> finalizeSession() async {
    if (submitting) return;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalize attendance?'),
        content: const Text(
          'This closes the session and may create absences for eligible students without a record.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finalize'),
          ),
        ],
      ),
    );
    if (proceed != true) return;
    setState(() => submitting = true);
    try {
      await api.dio.post(
        ApiEndpoints.teacherSession(ApiEndpoints.teacherFinalize, id),
      );
      await load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session finalization completed.')),
        );
      }
    } catch (exception) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(api.message(exception))));
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('${widget.session['course'] ?? 'Class session'}'),
    ),
    body: RefreshIndicator(
      onRefresh: load,
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error!, textAlign: TextAlign.center),
                  OutlinedButton(
                    onPressed: load,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                AppSurface(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${widget.session['section'] ?? 'Section'}'),
                    subtitle: Text(
                      '${widget.session['date'] ?? ''}  ${widget.session['start_at'] ?? ''}',
                    ),
                    trailing: StatusChip(
                      label: '${widget.session['status'] ?? 'scheduled'}',
                      color: statusColor('${widget.session['status'] ?? ''}'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (attendanceSummary.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 18,
                        runSpacing: 8,
                        children: attendanceSummary.entries
                            .map(
                              (entry) => Text(
                                '${entry.key}: ${entry.value}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  'Eligible students',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                if (students.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text('No eligible students found.'),
                    ),
                  ),
                ...students.map(
                  (student) => Card(
                    child: ListTile(
                      title: Text(
                        '${student['name'] ?? student['student_id']}',
                      ),
                      subtitle: Text('${student['student_id'] ?? ''}'),
                      trailing: submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              onPressed: () => mark(student),
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: AppColors.blue,
                              ),
                              tooltip: 'Mark attendance',
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.session['status'] != 'cancelled')
                  FilledButton.icon(
                    onPressed: submitting ? null : finalizeSession,
                    icon: const Icon(Icons.lock_clock_outlined),
                    label: const Text('Finalize session'),
                  ),
              ],
            ),
    ),
  );
}
