import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/courses/presentation/courses_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/events/presentation/events_page.dart';
import '../features/groups/presentation/groups_page.dart';
import '../features/library/presentation/library_page.dart';
import '../features/messages/presentation/message_read_state_controller.dart';
import '../features/profile/presentation/profile_page.dart';
import '../core/providers.dart';
import '../core/widgets/ambient_scaffold.dart';
import '../core/widgets/compact_text_scale.dart';

class AppShellPage extends ConsumerWidget {
  const AppShellPage({
    required this.currentTab,
    required this.onTabSelected,
    this.groupsInitialTab,
    super.key,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;
  final String? groupsInitialTab;

  static const List<AppTab> _navigationTabs = <AppTab>[
    AppTab.dashboard,
    AppTab.courses,
    AppTab.library,
    AppTab.groups,
    AppTab.events,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedNavigationIndex = _navigationTabs.contains(currentTab)
        ? _navigationTabs.indexOf(currentTab)
        : 0;
    final readMarkers = ref.watch(messageReadStateProvider);
    final unreadMessageCount = ref.watch(messageThreadsProvider).maybeWhen<int>(
          data: (threads) => threads.fold<int>(
            0,
            (total, thread) =>
                total + visibleUnreadCountForThread(thread, readMarkers),
          ),
          orElse: () => 0,
        );

    return AmbientScaffold(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            child: Row(
              children: <Widget>[
                IconButton.filledTonal(
                  onPressed: () => onTabSelected(AppTab.profile),
                  icon: Icon(
                    currentTab == AppTab.profile
                        ? Icons.account_circle_rounded
                        : Icons.account_circle_outlined,
                  ),
                  tooltip: 'Profile',
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () =>
                      context.push('/app/${currentTab.slug}/messages'),
                  icon: _HeaderBadgeIcon(
                    icon: Icons.mail_outline_rounded,
                    count: unreadMessageCount,
                  ),
                  tooltip: 'Messages',
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () =>
                      context.push('/app/${currentTab.slug}/notifications'),
                  icon: const Icon(Icons.notifications_outlined),
                  tooltip: 'Notifications',
                ),
                const Spacer(),
                Image.asset(
                  'assets/images/desktop-logo-OFCLearn.png',
                  height: 44,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          Expanded(child: _pageFor(currentTab)),
          CompactTextScale(
            maxScaleFactor: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: NavigationBar(
                selectedIndex: selectedNavigationIndex,
                onDestinationSelected: (index) =>
                    onTabSelected(_navigationTabs[index]),
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
                      icon: Icon(Icons.library_books_outlined),
                      selectedIcon: Icon(Icons.library_books_rounded),
                      label: 'Library'),
                  NavigationDestination(
                      icon: Icon(Icons.groups_outlined),
                      selectedIcon: Icon(Icons.groups_rounded),
                      label: 'Groups'),
                  NavigationDestination(
                      icon: Icon(Icons.event_outlined),
                      selectedIcon: Icon(Icons.event_rounded),
                      label: 'Events'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageFor(AppTab tab) {
    switch (tab) {
      case AppTab.dashboard:
        return const DashboardPage();
      case AppTab.courses:
        return const CoursesPage();
      case AppTab.library:
        return const LibraryPage();
      case AppTab.groups:
        return GroupsPage(initialTab: groupsInitialTab);
      case AppTab.events:
        return const EventsPage();
      case AppTab.profile:
        return const ProfilePage();
    }
  }
}

class _HeaderBadgeIcon extends StatelessWidget {
  const _HeaderBadgeIcon({
    required this.icon,
    required this.count,
  });

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return Icon(icon);
    }

    return Badge.count(
      count: count > 99 ? 99 : count,
      isLabelVisible: true,
      child: Icon(icon),
    );
  }
}

enum AppTab {
  dashboard('dashboard', 'Mission Control'),
  courses('courses', 'Courses'),
  library('library', 'Library'),
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
      case AppTab.library:
        return const LibraryPage();
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
