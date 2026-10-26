import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/api/api_client.dart';
import '../../../core/widgets/app_ui.dart';

class StudentDetailView extends StatefulWidget {
  final String title;
  final String endpoint;
  const StudentDetailView({
    super.key,
    required this.title,
    required this.endpoint,
  });
  @override
  State<StudentDetailView> createState() => _StudentDetailViewState();
}

class _StudentDetailViewState extends State<StudentDetailView> {
  final api = Get.find<ApiClient>();
  bool loading = true, loadingMore = false;
  String? error;
  int page = 1, lastPage = 1;
  List<Map<String, dynamic>> rows = [];
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load({bool refresh = true}) async {
    if (refresh) {
      if (loadingMore) return;
      setState(() {
        loading = true;
        page = 1;
        lastPage = 1;
        rows = [];
      });
    } else {
      if (loadingMore || page >= lastPage) return;
      setState(() => loadingMore = true);
    }
    try {
      final requestedPage = refresh ? 1 : page + 1;
      final response = await api.dio.get(
        widget.endpoint,
        queryParameters: {'page': requestedPage, 'per_page': 20},
      );
      final data = response.data['data'];
      final list = data is Map ? data['items'] : data;
      final incoming = list is List
          ? list
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : <Map<String, dynamic>>[];
      final metadata = data is Map && data['pagination'] is Map
          ? Map<String, dynamic>.from(data['pagination'])
          : <String, dynamic>{};
      if (refresh) {
        rows = incoming;
      } else {
        rows.addAll(
          incoming.where(
            (item) => !rows.any((existing) => existing['id'] == item['id']),
          ),
        );
      }
      page = metadata['current_page'] is int
          ? metadata['current_page'] as int
          : requestedPage;
      lastPage = metadata['last_page'] is int
          ? metadata['last_page'] as int
          : page;
      error = null;
    } catch (exception) {
      error = api.message(exception);
    }
    if (mounted) {
      setState(() {
        loading = false;
        loadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: RefreshIndicator(
      onRefresh: () => load(),
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error!, textAlign: TextAlign.center),
                  OutlinedButton(
                    onPressed: () => load(),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            )
          : rows.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 180),
                Icon(Icons.inbox_outlined, size: 48, color: AppColors.muted),
                Center(child: Text('No records available for this view.')),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length + (page < lastPage ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                if (index == rows.length) {
                  load(refresh: false);
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final row = rows[index];
                final status = '${row['status'] ?? row['action'] ?? ''}';
                return AppSurface(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.receipt_long_outlined,
                      color: AppColors.blue,
                    ),
                    title: Text(
                      '${row['course'] ?? row['type'] ?? row['action'] ?? row['status'] ?? 'Record'}',
                    ),
                    subtitle: Text(
                      '${row['marked_at'] ?? row['event_at'] ?? row['created_at'] ?? row['message'] ?? ''}',
                    ),
                    trailing: status.isEmpty
                        ? null
                        : StatusChip(label: status, color: statusColor(status)),
                  ),
                );
              },
            ),
    ),
  );
}
