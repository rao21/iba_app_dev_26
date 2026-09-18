import 'package:flutter/material.dart';

/// A course a student is registered in this semester.
class Course {
  const Course({
    required this.code,
    required this.title,
    required this.credits,
    required this.instructor,
    required this.grade,
  });

  final String code;
  final String title;
  final int credits;
  final String instructor;
  final String grade;
}

/// Everything the profile screen shows. In a real app this arrives from an
/// API; here it is a const so the screen has something honest to render.
class Student {
  const Student({
    required this.name,
    required this.rollNumber,
    required this.programme,
    required this.batch,
    required this.email,
    required this.cgpa,
    required this.semester,
    required this.courses,
  });

  final String name;
  final String rollNumber;
  final String programme;
  final String batch;
  final String email;
  final double cgpa;
  final int semester;
  final List<Course> courses;

  String get initials => name
      .split(' ')
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();

  int get creditHours =>
      courses.fold(0, (total, course) => total + course.credits);
}

const student = Student(
  name: 'Rao Noman',
  rollNumber: '26451',
  programme: 'BS Computer Science',
  batch: 'Batch of 2026',
  email: 'rao.noman.26451@khi.iba.edu.pk',
  cgpa: 3.62,
  semester: 5,
  courses: [
    Course(
      code: 'CSE 342',
      title: 'App Development',
      credits: 3,
      instructor: 'Sir Kamran',
      grade: 'A',
    ),
    Course(
      code: 'CSE 271',
      title: 'Data Structures',
      credits: 4,
      instructor: 'Dr. Sadaf',
      grade: 'B+',
    ),
    Course(
      code: 'CSE 311',
      title: 'Database Systems',
      credits: 3,
      instructor: 'Sir Faizan',
      grade: 'A-',
    ),
    Course(
      code: 'MKT 201',
      title: 'Marketing Management',
      credits: 3,
      instructor: 'Ms. Hina',
      grade: 'B',
    ),
    Course(
      code: 'ENG 102',
      title: 'Business Communication',
      credits: 2,
      instructor: 'Ms. Ayesha',
      grade: 'A',
    ),
  ],
);

/// The Profile tab: an animated SliverAppBar that collapses from a full
/// portrait header down to a plain title bar, then three stats and the
/// semester's courses — built only from widgets covered in the gallery.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.data = student, this.onToggleTheme});

  final Student data;

  /// Shown as an action on the collapsed bar. Optional so the page still
  /// works when opened on its own, outside the gallery shell.
  final VoidCallback? onToggleTheme;

  static const _expandedHeight = 260.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: _expandedHeight,
          pinned: true, // stays on screen, collapsed, once scrolled past
          stretch: true, // overscroll at the top gently stretches the header
          title: Text(data.name), // only visible once collapsed
          actions: [
            if (onToggleTheme != null)
              IconButton(
                onPressed: onToggleTheme,
                icon: const Icon(Icons.brightness_6_outlined),
                tooltip: 'Toggle light and dark',
              ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
            ],
            // Fades the plain title above out as the portrait fades in, so
            // the two never overlap mid-collapse.
            titlePadding: EdgeInsets.zero,
            background: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [scheme.primary, scheme.primaryContainer],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'profile-avatar',
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: scheme.onPrimary,
                          child: Text(
                            data.initials,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: scheme.onPrimary,
                        ),
                      ),
                      Text(
                        '${data.programme} · ${data.batch}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text('Roll ${data.rollNumber}'),
                            visualDensity: VisualDensity.compact,
                          ),
                          Chip(
                            label: Text('Semester ${data.semester}'),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Stats
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                _Stat(label: 'CGPA', value: data.cgpa.toStringAsFixed(2)),
                _Stat(label: 'Credit hours', value: '${data.creditHours}'),
                _Stat(label: 'Courses', value: '${data.courses.length}'),
              ],
            ),
          ),
        ),

        // Contact
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          sliver: SliverToBoxAdapter(
            child: Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.mail_outline),
                    title: const Text('Email'),
                    subtitle: Text(data.email),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('Roll number'),
                    subtitle: Text(data.rollNumber),
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          sliver: SliverToBoxAdapter(
            child: Text('This semester', style: theme.textTheme.titleMedium),
          ),
        ),

        // Courses — SliverList.builder so the row widgets are only built as
        // they scroll near the viewport, same as ListView.builder would.
        SliverList.builder(
          itemCount: data.courses.length,
          itemBuilder: (context, i) {
            final course = data.courses[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: scheme.secondaryContainer,
                child: Text(
                  course.grade,
                  style: TextStyle(
                    color: scheme.onSecondaryContainer,
                    fontSize: 13,
                  ),
                ),
              ),
              title: Text(course.title),
              subtitle: Text('${course.code} · ${course.instructor}'),
              trailing: Text('${course.credits} cr'),
            );
          },
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

/// One figure in the stats row. Expanded so the three share the width evenly.
class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text(value, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
