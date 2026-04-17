import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/widgets/section_card.dart';
import '../domain/course_summary.dart';

class CoursesPage extends ConsumerWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider);

    return courses.when(
      data: (items) => _CourseList(items: items),
      error: (error, _) => Center(child: Text(error.toString())),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _CourseList extends StatelessWidget {
  const _CourseList({required this.items});

  final List<CourseSummary> items;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final course = items[index];
          return SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(course.title,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(course.excerpt.isEmpty
                    ? 'No excerpt yet.'
                    : course.excerpt),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _MetaChip(
                        label: course.authorName.isEmpty
                            ? 'Unknown author'
                            : course.authorName),
                    _MetaChip(label: course.status),
                    if (course.price.isNotEmpty) _MetaChip(label: course.price),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5F2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label),
      ),
    );
  }
}
