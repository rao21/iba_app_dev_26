import 'package:flutter/material.dart';

/// One entry in the gallery.
///
/// Every card shows the same three things in the same order: what the widget
/// is called, the live widget itself, and the exact code that produced it.
class DemoCard extends StatelessWidget {
  const DemoCard({
    super.key,
    required this.title,
    required this.note,
    required this.code,
    required this.child,
  });

  /// The widget's name, e.g. `Row + Expanded`.
  final String title;

  /// One line on when to reach for it.
  final String note;

  /// The snippet that built [child], shown verbatim.
  final String code;

  /// The running example.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  note,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: child,
          ),
          CodeBlock(code: code),
        ],
      ),
    );
  }
}

/// Collapsed source view. Horizontal scrolling keeps long lines intact instead
/// of wrapping them into something that no longer compiles.
class CodeBlock extends StatelessWidget {
  const CodeBlock({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        dense: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(Icons.code, size: 20, color: scheme.onSurfaceVariant),
        title: Text('Show code', style: Theme.of(context).textTheme.labelLarge),
        children: [
          Container(
            width: double.infinity,
            color: scheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A labelled band used inside layout demos so the boxes being arranged are
/// visible without adding a real widget to the example.
class Swatch extends StatelessWidget {
  const Swatch(this.label, {super.key, this.height = 48, this.color});

  final String label;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: height,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color ?? scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: scheme.onSecondaryContainer)),
    );
  }
}
