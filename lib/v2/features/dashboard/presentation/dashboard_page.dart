import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../auth/presentation/auth_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final stats = ref.watch(dashboardStatsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: <Widget>[
        Text(
          'Good to see you, ${session?.user.displayName.isNotEmpty == true ? session!.user.displayName : session?.user.username ?? 'coach'}.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'This branch is the clean migration target for the new OFC Learn client.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        stats.when(
          data: (value) => Wrap(
            spacing: 14,
            runSpacing: 14,
            children: <Widget>[
              _MetricCard(
                  label: 'Courses',
                  value: value.courses.toString(),
                  tone: const Color(0xFFDCEBE7)),
              _MetricCard(
                  label: 'Groups',
                  value: value.groups.toString(),
                  tone: const Color(0xFFF2E5C8)),
              _MetricCard(
                  label: 'Archived Events',
                  value: value.previousEvents.toString(),
                  tone: const Color(0xFFF0DCCF)),
              _MetricCard(
                  label: 'Upcoming Events',
                  value: value.upcomingEvents.toString(),
                  tone: const Color(0xFFE4E9F4)),
            ],
          ),
          error: (error, _) => Text(error.toString()),
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class DashboardStats {
  const DashboardStats({
    required this.courses,
    required this.groups,
    required this.previousEvents,
    required this.upcomingEvents,
  });

  final int courses;
  final int groups;
  final int previousEvents;
  final int upcomingEvents;
}
