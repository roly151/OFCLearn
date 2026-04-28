import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/v2_theme.dart';
import '../../../core/dependencies.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/compact_text_scale.dart';
import '../../../core/widgets/section_card.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/profile_models.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileOverviewProvider);

    return DefaultTabController(
      length: 3,
      child: profileAsync.when(
        data: (profile) => Column(
          children: <Widget>[
            _ProfileHeader(profile: profile),
            const CompactTextScale(
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: <Widget>[
                  Tab(text: 'Profile'),
                  Tab(text: 'Connections'),
                  Tab(text: 'Qualifications'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  _ProfileDetailsTab(profile: profile),
                  const _ConnectionsTab(),
                  const _QualificationsTab(),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(profileOverviewProvider),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final ProfileOverview profile;

  @override
  Widget build(BuildContext context) {
    final user = profile.user;
    final coverUrl = user.coverUrl.trim();
    final avatarUrl = user.avatarThumbUrl.trim().isNotEmpty
        ? user.avatarThumbUrl.trim()
        : user.avatarUrl.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: SectionCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              child: AspectRatio(
                aspectRatio: 3.6,
                child: coverUrl.isEmpty
                    ? Container(color: V2Palette.navIndicator)
                    : Image.network(
                        coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: V2Palette.navIndicator),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: V2Palette.navIndicator,
                      backgroundImage:
                          avatarUrl.isEmpty ? null : NetworkImage(avatarUrl),
                      child: avatarUrl.isEmpty
                          ? Text(
                              user.initials,
                              style: Theme.of(context).textTheme.titleLarge,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            user.displayName,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text('@${user.username}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDetailsTab extends ConsumerStatefulWidget {
  const _ProfileDetailsTab({required this.profile});

  final ProfileOverview profile;

  @override
  ConsumerState<_ProfileDetailsTab> createState() => _ProfileDetailsTabState();
}

class _ProfileDetailsTabState extends ConsumerState<_ProfileDetailsTab> {
  final Map<int, TextEditingController> _controllers =
      <int, TextEditingController>{};
  final Map<int, String> _selectedValues = <int, String>{};
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _syncFields(widget.profile.groups);
  }

  @override
  void didUpdateWidget(covariant _ProfileDetailsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile && !_editing) {
      _syncFields(widget.profile.groups);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncFields(List<ProfileFieldGroup> groups) {
    final liveIds = <int>{};
    for (final group in _visibleProfileGroups(groups)) {
      for (final field in group.fields) {
        liveIds.add(field.id);
        _controllers.putIfAbsent(field.id, () => TextEditingController()).text =
            field.value;
        _selectedValues[field.id] = field.value;
      }
    }

    for (final id in _controllers.keys.toList()) {
      if (!liveIds.contains(id)) {
        _controllers.remove(id)?.dispose();
        _selectedValues.remove(id);
      }
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final fields = <int, Object>{};

    for (final group in _visibleProfileGroups(widget.profile.groups)) {
      for (final field in group.fields.where((field) => field.editable)) {
        fields[field.id] = field.hasOptions && !field.isMultiValue
            ? (_selectedValues[field.id] ?? '')
            : (_controllers[field.id]?.text.trim() ?? '');
      }
    }

    try {
      final result =
          await ref.read(profileRepositoryProvider).updateProfileFields(fields);
      ref.invalidate(profileOverviewProvider);
      await ref.read(authControllerProvider.notifier).refreshProfile();
      if (!mounted) {
        return;
      }
      setState(() {
        _editing = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(profileOverviewProvider),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: _editing
                ? Wrap(
                    spacing: 8,
                    children: <Widget>[
                      OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () {
                                _syncFields(widget.profile.groups);
                                setState(() => _editing = false);
                              },
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        child: Text(_saving ? 'Saving...' : 'Save'),
                      ),
                    ],
                  )
                : FilledButton.icon(
                    onPressed: () => setState(() => _editing = true),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
          ),
          const SizedBox(height: 12),
          for (final group
              in _visibleProfileGroups(widget.profile.groups)) ...<Widget>[
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(group.name,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  for (final field in group.fields)
                    _ProfileFieldRow(
                      field: field,
                      editing: _editing && field.editable,
                      controller: _controllers[field.id],
                      selectedValue: _selectedValues[field.id],
                      onSelected: (value) =>
                          setState(() => _selectedValues[field.id] = value),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          FilledButton.icon(
            onPressed: () => context.push('/change-password'),
            icon: const Icon(Icons.lock_reset_rounded),
            label: const Text('Change password'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileFieldRow extends StatelessWidget {
  const _ProfileFieldRow({
    required this.field,
    required this.editing,
    required this.controller,
    required this.selectedValue,
    required this.onSelected,
  });

  final ProfileField field;
  final bool editing;
  final TextEditingController? controller;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final value = field.value.trim().isEmpty ? 'Not set' : field.value.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: editing
          ? _input(context)
          : LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 520;
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(field.name,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(value, style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 220,
                      child: Text(
                        field.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        value,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _input(BuildContext context) {
    if (field.hasOptions && !field.isMultiValue) {
      final optionValues = field.options.map((option) => option.value).toSet();
      final current =
          optionValues.contains(selectedValue) ? selectedValue : null;

      return DropdownButtonFormField<String>(
        initialValue: current,
        decoration: InputDecoration(
          labelText: field.required ? '${field.name} *' : field.name,
        ),
        items: field.options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option.value,
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(growable: false),
        isExpanded: true,
        selectedItemBuilder: (context) => field.options
            .map(
              (option) => Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(growable: false),
        onChanged: (value) {
          if (value != null) {
            onSelected(value);
          }
        },
      );
    }

    return TextFormField(
      controller: controller,
      minLines: field.type == 'textarea' ? 3 : 1,
      maxLines: field.type == 'textarea' ? 5 : 1,
      decoration: InputDecoration(
        labelText: field.required ? '${field.name} *' : field.name,
        helperText: field.description.isEmpty ? null : field.description,
      ),
    );
  }
}

class _ConnectionsTab extends ConsumerWidget {
  const _ConnectionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionsAsync = ref.watch(profileConnectionsProvider);
    return connectionsAsync.when(
      data: (connections) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(profileConnectionsProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: <Widget>[
            if (connections.isEmpty)
              const _EmptyCard(message: 'No connections found.'),
            for (final connection in connections) ...<Widget>[
              SectionCard(
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 26,
                      backgroundImage: connection.avatarUrl.isEmpty
                          ? null
                          : NetworkImage(connection.avatarUrl),
                      child: connection.avatarUrl.isEmpty
                          ? Text(_initials(connection.displayName))
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        connection.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => context.push(
                        '/app/profile/messages/direct/${connection.id}',
                      ),
                      child: const Text('message'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(profileConnectionsProvider),
      ),
    );
  }
}

class _QualificationsTab extends ConsumerWidget {
  const _QualificationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qualificationsAsync = ref.watch(profileQualificationsProvider);
    return qualificationsAsync.when(
      data: (qualifications) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(profileQualificationsProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: <Widget>[
            Text(
              'Accreditation Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (qualifications.accreditations.isEmpty)
              const _EmptyCard(message: 'No accreditations found.')
            else
              for (final item in qualifications.accreditations) ...<Widget>[
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.title.isEmpty ? 'Accreditation' : item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Expires ${item.expiryDate}'),
                      if (item.certificateLink.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () =>
                              launchUrl(Uri.parse(item.certificateLink)),
                          icon: const Icon(Icons.workspace_premium_outlined),
                          label: const Text('Certificate'),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            const SizedBox(height: 12),
            Text(
              'Continued Professional Development',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _CpdSummaryCard(cpd: qualifications.cpd),
            const SizedBox(height: 12),
            for (final earning in qualifications.cpd.earnings) ...<Widget>[
              _CpdEarningCard(earning: earning),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(profileQualificationsProvider),
      ),
    );
  }
}

class _CpdSummaryCard extends StatelessWidget {
  const _CpdSummaryCard({required this.cpd});

  final CpdOverview cpd;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: <Widget>[
          _CpdThumbnail(url: cpd.thumbnail, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  cpd.total.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(cpd.label),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CpdEarningCard extends StatelessWidget {
  const _CpdEarningCard({required this.earning});

  final CpdEarning earning;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _CpdThumbnail(url: earning.thumbnail, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(earning.title,
                    style: Theme.of(context).textTheme.titleMedium),
                if (earning.description.isNotEmpty) Text(earning.description),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: <Widget>[
                    if (earning.date.isNotEmpty) Text(earning.date),
                    Text('${earning.points} ${earning.pointsLabel}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CpdThumbnail extends StatelessWidget {
  const _CpdThumbnail({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: url.isEmpty
          ? const Icon(Icons.school_outlined)
          : Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.school_outlined),
            ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SectionCard(child: Text(message));
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

String _initials(String value) {
  final parts = value.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}

List<ProfileFieldGroup> _visibleProfileGroups(List<ProfileFieldGroup> groups) {
  return groups
      .where((group) => !_isHiddenProfileGroup(group))
      .map(
        (group) => ProfileFieldGroup(
          id: group.id,
          name: group.name,
          fields: group.fields
              .where((field) => !_isHiddenProfileField(field))
              .toList(growable: false),
        ),
      )
      .where((group) => group.fields.isNotEmpty)
      .toList(growable: false);
}

bool _isHiddenProfileGroup(ProfileFieldGroup group) {
  return _normalizedProfileLabel(group.name) == 'about';
}

bool _isHiddenProfileField(ProfileField field) {
  const hiddenLabels = <String>{
    'participantconsent',
    'participantconsentbox',
    'suburbtownname',
    'clubname',
  };

  return hiddenLabels.contains(_normalizedProfileLabel(field.name));
}

String _normalizedProfileLabel(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}
