import 'package:flutter/material.dart';

/// GET, POST, PUT, DELETE — coloured the way every API tool colours them, so
/// the colour becomes a vocabulary word before the student reads a line of
/// code. Deliberately outside the app's theme: this is a fixed convention,
/// not a design choice per screen.
class MethodBadge extends StatelessWidget {
  const MethodBadge(this.method, {super.key});

  final String method;

  static const _colors = {
    'GET': Color(0xFF2E7DD1),
    'POST': Color(0xFF2F9E5C),
    'PUT': Color(0xFFCC8B14),
    'DELETE': Color(0xFFD1483C),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[method] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: .4,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

/// An HTTP status code, coloured by its class (2xx / 4xx / 5xx) the way a
/// browser network tab colours it.
class StatusChip extends StatelessWidget {
  const StatusChip(this.code, {super.key});

  final int code;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (code) {
      >= 200 && < 300 => const Color(0xFF2F9E5C),
      >= 400 && < 500 => const Color(0xFFCC8B14),
      >= 500 => const Color(0xFFD1483C),
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$code',
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

/// One line: METHOD + endpoint, exactly what a student should learn to read
/// before anything else — every request is just this.
class RequestBar extends StatelessWidget {
  const RequestBar({
    super.key,
    required this.method,
    required this.path,
    this.status,
  });

  final String method;
  final String path;
  final int? status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          MethodBadge(method),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              path,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (status != null) ...[
            const SizedBox(width: 10),
            StatusChip(status!),
          ],
        ],
      ),
    );
  }
}

/// The lecture banner every teaching section opens with: number, title, one
/// line on what the student should walk away knowing.
class LectureBanner extends StatelessWidget {
  const LectureBanner({
    super.key,
    required this.number,
    required this.title,
    required this.summary,
  });

  final String number;
  final String title;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LECTURE $number',
            style: TextStyle(
              color: scheme.onPrimary.withValues(alpha: 0.85),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

/// A short heading for a sub-section within the lecture, e.g. "Reading a
/// list — GET". Keeps the page scannable without another full DemoCard.
class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
