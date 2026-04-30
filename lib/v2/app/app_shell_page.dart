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
import 'v2_theme.dart';

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
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _AppBottomNavigation(
              currentTab: currentTab,
              onTabSelected: onTabSelected,
              tabs: _navigationTabs,
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

class _AppBottomNavigation extends StatelessWidget {
  const _AppBottomNavigation({
    required this.currentTab,
    required this.onTabSelected,
    required this.tabs,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;
  final List<AppTab> tabs;

  static const Map<AppTab, _BottomNavigationItemData> _items =
      <AppTab, _BottomNavigationItemData>{
    AppTab.dashboard: _BottomNavigationItemData(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    AppTab.courses: _BottomNavigationItemData(
      label: 'Courses',
      icon: Icons.school_outlined,
      selectedIcon: Icons.school_rounded,
    ),
    AppTab.library: _BottomNavigationItemData(
      label: 'Library',
      icon: Icons.library_books_outlined,
      selectedIcon: Icons.library_books_rounded,
    ),
    AppTab.groups: _BottomNavigationItemData(
      label: 'Groups',
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups_rounded,
    ),
    AppTab.events: _BottomNavigationItemData(
      label: 'Events',
      icon: Icons.event_outlined,
      selectedIcon: Icons.event_rounded,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return CompactTextScale(
      maxScaleFactor: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: V2Palette.surface,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: SizedBox(
            height: 78,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final labelFontSize = _labelFontSizeFor(
                  context,
                  constraints.maxWidth / tabs.length,
                );

                return Row(
                  children: tabs.map((tab) {
                    final item = _items[tab]!;
                    return Expanded(
                      child: _BottomNavigationItem(
                        data: item,
                        selected: tab == currentTab,
                        labelFontSize: labelFontSize,
                        onTap: () => onTabSelected(tab),
                      ),
                    );
                  }).toList(growable: false),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double _labelFontSizeFor(BuildContext context, double itemWidth) {
    const baseFontSize = 15.0;
    final availableWidth = itemWidth - 4;
    final textStyle = TextStyle(
      fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
      fontSize: baseFontSize,
      fontWeight: FontWeight.w700,
      height: 1,
    );
    final painter = TextPainter(
      text: const TextSpan(text: 'Dashboard'),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: TextScaler.noScaling,
    )..text = TextSpan(text: 'Dashboard', style: textStyle);

    painter.layout();

    if (painter.width <= availableWidth) {
      return baseFontSize;
    }

    return baseFontSize * (availableWidth / painter.width);
  }
}

class _BottomNavigationItemData {
  const _BottomNavigationItemData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _BottomNavigationItem extends StatelessWidget {
  const _BottomNavigationItem({
    required this.data,
    required this.selected,
    required this.labelFontSize,
    required this.onTap,
  });

  final _BottomNavigationItemData data;
  final bool selected;
  final double labelFontSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? V2Palette.primaryBlue : V2Palette.ink;

    return Semantics(
      button: true,
      selected: selected,
      label: data.label,
      child: Tooltip(
        message: data.label,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: 68,
                  height: 42,
                  decoration: BoxDecoration(
                    color:
                        selected ? V2Palette.navIndicator : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(
                    selected ? data.selectedIcon : data.icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: double.infinity,
                  height: 20,
                  child: Center(
                    child: Text(
                      data.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        color: color,
                        fontSize: labelFontSize,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
