import 'package:flutter/material.dart';

import '../widgets/demo_card.dart';

/// What setState actually does, made visible: every rebuild appends a line to
/// the log, so the class can see build() run.
class StatePage extends StatefulWidget {
  const StatePage({super.key});

  @override
  State<StatePage> createState() => _StatePageState();
}

class _StatePageState extends State<StatePage> {
  int _count = 0;
  int _builds = 0;
  final List<String> _log = [];

  @override
  void initState() {
    super.initState();
    // Runs once, before the first build. Load data here, never in build().
    _log.add('initState() → _count = 0');
  }

  void _increment() {
    setState(() {
      _count++;
      _log.add('setState() → _count = $_count');
    });
  }

  void _incrementWithoutSetState() {
    // Deliberately wrong: the field really does change, but nothing tells
    // Flutter to rebuild, so the number above stays where it was.
    _count++;
    _log.add('_count = $_count  (no setState — screen is now stale)');
  }

  void _reset() {
    setState(() {
      _count = 0;
      _builds = 0;
      _log
        ..clear()
        ..add('reset → _count = 0');
    });
  }

  @override
  Widget build(BuildContext context) {
    _builds++;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        DemoCard(
          title: 'setState',
          note: 'It does not repaint. It marks this widget dirty so Flutter '
              'calls build() again on the next frame.',
          code: '''
int _count = 0;

void _increment() {
  setState(() {
    _count++;
  });
}''',
          child: Column(
            children: [
              Text('$_count', style: theme.textTheme.displaySmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: _increment,
                    icon: const Icon(Icons.add),
                    label: const Text('setState'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _incrementWithoutSetState,
                    icon: const Icon(Icons.warning_amber),
                    label: const Text('without setState'),
                  ),
                  TextButton(onPressed: _reset, child: const Text('Reset')),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Press "without setState" and the number stops moving — but '
                'the log keeps counting. That gap is the bug everyone hits '
                'once.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        DemoCard(
          title: 'build() runs again, in full',
          note: 'build() has run $_builds time${_builds == 1 ? '' : 's'} since '
              'this page opened. Keep it cheap: no network calls, no loops '
              'over large data, no file reads.',
          code: '''
@override
Widget build(BuildContext context) {
  _builds++;              // just for this demo — never mutate state in build
  return Text('\$_count');
}''',
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in _log.reversed.take(8))
                  Text(
                    line,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      height: 1.6,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const DemoCard(
          title: 'Stateless vs Stateful',
          note: 'One question: does anything here change while the user is '
              'looking at it?',
          code: '''
// No → StatelessWidget. One class, one build method.
class Greeting extends StatelessWidget {
  const Greeting({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) => Text('Hello, \$name');
}

// Yes → StatefulWidget. The widget stays immutable; the State holds the value.
class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}''',
          child: Swatch('when in doubt, start Stateless', height: 40),
        ),
      ],
    );
  }
}
