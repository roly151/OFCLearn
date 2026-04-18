import 'package:flutter/material.dart';

import 'v2_theme.dart';
import '../features/courses/presentation/courses_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/events/presentation/events_page.dart';
import '../features/groups/presentation/groups_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../core/widgets/ambient_scaffold.dart';

class AppShellPage extends StatelessWidget {
  const AppShellPage({
    required this.currentTab,
    required this.onTabSelected,
    super.key,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return AmbientScaffold(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('OFC Learn v2',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        'Clean client architecture on top of ofc-mobile/v1',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: V2Palette.surface.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: V2Palette.cardBorder),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(currentTab.title),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: currentTab.page),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: NavigationBar(
              selectedIndex: AppTab.values.indexOf(currentTab),
              onDestinationSelected: (index) =>
                  onTabSelected(AppTab.values[index]),
              destinations: const <NavigationDestination>[
                NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard_rounded),
                    label: 'Dashboard'),
                NavigationDestination(
                    icon: Icon(Icons.school_outlined),
                    selectedIcon: Icon(Icons.school_rounded),
                    label: 'Courses'),
                NavigationDestination(
                    icon: Icon(Icons.groups_outlined),
                    selectedIcon: Icon(Icons.groups_rounded),
                    label: 'Groups'),
                NavigationDestination(
                    icon: Icon(Icons.event_outlined),
                    selectedIcon: Icon(Icons.event_rounded),
                    label: 'Events'),
                NavigationDestination(
                    icon: Icon(Icons.account_circle_outlined),
                    selectedIcon: Icon(Icons.account_circle_rounded),
                    label: 'Profile'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum AppTab {
  dashboard('dashboard', 'Mission Control'),
  courses('courses', 'Courses'),
  groups('groups', 'Groups'),
  events('events', 'Events'),
  profile('profile', 'Profile');

  const AppTab(this.slug, this.title);

  final String slug;
  final String title;

  Widget get page {
    switch (this) {
      case AppTab.dashboard:
        return const DashboardPage();
      case AppTab.courses:
        return const CoursesPage();
      case AppTab.groups:
        return const GroupsPage();
      case AppTab.events:
        return const EventsPage();
      case AppTab.profile:
        return const ProfilePage();
    }
  }

  static AppTab fromSlug(String? slug) {
    return AppTab.values.firstWhere(
      (tab) => tab.slug == slug,
      orElse: () => AppTab.dashboard,
    );
  }
}
