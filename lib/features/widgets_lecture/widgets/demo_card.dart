import 'package:flutter/material.dart';

import '../../../shared/widgets/code_block.dart';

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
