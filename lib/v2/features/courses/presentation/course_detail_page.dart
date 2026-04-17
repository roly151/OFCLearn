import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_shell_page.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/ambient_scaffold.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/section_card.dart';
import '../domain/course_detail.dart';

class CourseDetailPage extends ConsumerWidget {
  const CourseDetailPage({
    required this.tab,
    required this.courseId,
    super.key,
  });

  final AppTab tab;
  final int courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(courseDetailProvider(courseId));

    return AmbientScaffold(
      child: Column(
        children: <Widget>[
          _DetailTopBar(
            title: 'Course detail',
            onBack: () => context.go('/app/${tab.slug}'),
          ),
          const PageHeader(
            title: 'Course detail',
            subtitle:
                'Live detail from ofc-mobile/v1 with explicit retry and refresh behavior.',
          ),
          Expanded(
            child: detail.when(
              data: (course) => RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(courseDetailProvider(courseId).future),
                child: _CourseDetailContent(course: course),
              ),
              error: (error, _) => AsyncStateView(
                message: error.toString(),
                onRetry: () => ref.invalidate(courseDetailProvider(courseId)),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseDetailContent extends StatelessWidget {
  const _CourseDetailContent({required this.course});

  final CourseDetail course;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: <Widget>[
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                course.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(course.excerpt.isEmpty
                  ? 'No excerpt provided.'
                  : course.excerpt),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _DetailChip(
                    label: course.authorName.isEmpty
                        ? 'Unknown author'
                        : course.authorName,
                  ),
                  _DetailChip(label: course.status),
                  if (course.date.isNotEmpty) _DetailChip(label: course.date),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Overview', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                course.content.isEmpty
                    ? 'No course content yet.'
                    : _stripHtml(course.content),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (course.lessonLink.isNotEmpty) ...<Widget>[
                const SizedBox(height: 18),
                Text(
                  'First lesson link',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                SelectableText(course.lessonLink),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailTopBar extends StatelessWidget {
  const _DetailTopBar({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE7F0ED),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label),
      ),
    );
  }
}

String _stripHtml(String html) {
  return html
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
