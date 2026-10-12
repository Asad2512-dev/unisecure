import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../app/theme/app_colors.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('UniSecure'),
        actions: [
          IconButton(
            onPressed: auth.logout,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: auth.restore,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Welcome back, ${auth.user.value?.name ?? 'User'}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Role: ${auth.user.value?.role ?? 'unknown'}',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Your role-specific data will appear here from the configured UniSecure API.',
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Action(icon: Icons.school_outlined, label: 'Academic'),
                _Action(
                  icon: Icons.event_available_outlined,
                  label: 'Attendance',
                ),
                _Action(icon: Icons.notifications_none, label: 'Notifications'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Action({required this.icon, required this.label});
  @override
  Widget build(BuildContext c) => SizedBox(
    width: 150,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, color: AppColors.blue),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    ),
  );
}
