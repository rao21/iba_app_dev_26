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

/// The Profile tab: a header, three stats, and the semester's courses —
/// built only from widgets covered in the gallery.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.data = student});

  final Student data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Header
        Container(
          width: double.infinity,
          color: scheme.primaryContainer,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: scheme.primary,
                child: Text(
                  data.initials,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.name, style: theme.textTheme.titleLarge),
                    Text(
                      '${data.programme} · ${data.batch}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
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
            ],
          ),
        ),

        // Stats
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              _Stat(label: 'CGPA', value: data.cgpa.toStringAsFixed(2)),
              _Stat(label: 'Credit hours', value: '${data.creditHours}'),
              _Stat(label: 'Courses', value: '${data.courses.length}'),
            ],
          ),
        ),

        // Contact
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text('This semester', style: theme.textTheme.titleMedium),
        ),

        // Courses — a plain for-loop because the list is short and already
        // inside a scrolling ListView.
        for (final course in data.courses)
          ListTile(
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
          ),
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
