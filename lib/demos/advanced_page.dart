import 'package:flutter/material.dart';

import '../widgets/demo_card.dart';

/// The widgets that make an app feel finished: animation, async data,
/// swipe-to-delete, pull-to-refresh, steppers and slivers.
class AdvancedPage extends StatefulWidget {
  const AdvancedPage({super.key});

  @override
  State<AdvancedPage> createState() => _AdvancedPageState();
}

class _AdvancedPageState extends State<AdvancedPage> {
  bool _expanded = false;
  int _step = 0;
  List<String> _tasks = ['Draw the widget tree', 'Build the card', 'Push the branch'];

  Future<String> _loadGrade() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return 'A-';
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _tasks = [..._tasks, 'Refreshed at ${DateTime.now().hour}h']);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        DemoCard(
          title: 'AnimatedContainer',
          note: 'Change any property and give it a duration — Flutter animates '
              'between the old value and the new one. No controller needed.',
          code: '''
AnimatedContainer(
  duration: const Duration(milliseconds: 350),
  curve: Curves.easeOutBack,
  width: _expanded ? 220 : 90,
  height: _expanded ? 90 : 56,
  decoration: BoxDecoration(
    color: _expanded ? scheme.primary : scheme.secondaryContainer,
    borderRadius: BorderRadius.circular(_expanded ? 24 : 8),
  ),
)''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                width: _expanded ? 220 : 90,
                height: _expanded ? 90 : 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _expanded ? scheme.primary : scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(_expanded ? 24 : 8),
                ),
                child: Text(
                  _expanded ? 'expanded' : 'tap →',
                  style: TextStyle(
                    color: _expanded ? scheme.onPrimary : scheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: const Text('Animate'),
              ),
            ],
          ),
        ),
        DemoCard(
          title: 'FutureBuilder',
          note: 'Builds from an async result. Always handle all three states: '
              'waiting, error, and data.',
          code: '''
FutureBuilder<String>(
  future: _loadGrade(),
  builder: (context, snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) return Text('Failed: \${snapshot.error}');
    return Text('Grade: \${snapshot.data}');
  },
)''',
          child: FutureBuilder<String>(
            future: _loadGrade(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Loading grade…'),
                  ],
                );
              }
              if (snapshot.hasError) {
                return Text('Failed: ${snapshot.error}');
              }
              return Text(
                'Grade: ${snapshot.data}',
                style: Theme.of(context).textTheme.titleLarge,
              );
            },
          ),
        ),
        DemoCard(
          title: 'Dismissible + RefreshIndicator',
          note: 'Swipe a row away, or pull the list down to reload. Every '
              'Dismissible needs a stable, unique key.',
          code: '''
RefreshIndicator(
  onRefresh: _refresh,
  child: ListView(
    children: [
      for (final task in _tasks)
        Dismissible(
          key: ValueKey(task),
          background: ColoredBox(color: Colors.red),
          onDismissed: (_) => setState(() => _tasks.remove(task)),
          child: ListTile(title: Text(task)),
        ),
    ],
  ),
)''',
          child: SizedBox(
            height: 200,
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  for (final task in _tasks)
                    Dismissible(
                      key: ValueKey(task),
                      background: ColoredBox(color: scheme.errorContainer),
                      onDismissed: (_) =>
                          setState(() => _tasks = [..._tasks]..remove(task)),
                      child: ListTile(
                        leading: const Icon(Icons.drag_indicator),
                        title: Text(task),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        DemoCard(
          title: 'Stepper',
          note: 'A multi-step form. You own the current step; Stepper only '
              'reports which way the user wants to go.',
          code: '''
Stepper(
  currentStep: _step,
  onStepContinue: () => setState(() => _step = (_step + 1).clamp(0, 2)),
  onStepCancel: () => setState(() => _step = (_step - 1).clamp(0, 2)),
  steps: const [
    Step(title: Text('Details'), content: Text('Name and roll number')),
    Step(title: Text('Courses'), content: Text('Pick five')),
    Step(title: Text('Confirm'), content: Text('Submit')),
  ],
)''',
          child: SizedBox(
            height: 300,
            child: Stepper(
              currentStep: _step,
              onStepContinue: () => setState(() => _step = (_step + 1).clamp(0, 2)),
              onStepCancel: () => setState(() => _step = (_step - 1).clamp(0, 2)),
              onStepTapped: (i) => setState(() => _step = i),
              steps: const [
                Step(title: Text('Details'), content: Text('Name and roll number')),
                Step(title: Text('Courses'), content: Text('Pick five')),
                Step(title: Text('Confirm'), content: Text('Submit')),
              ],
            ),
          ),
        ),
        const DemoCard(
          title: 'Hero',
          note: 'Same tag on two screens and Flutter animates the widget '
              'between them during the route transition.',
          code: '''
// on the list screen
Hero(tag: 'avatar-26451', child: CircleAvatar(child: Text('RN')))

// on the detail screen — same tag, bigger
Hero(tag: 'avatar-26451', child: CircleAvatar(radius: 48, child: Text('RN')))''',
          child: Row(
            children: [
              CircleAvatar(child: Text('RN')),
              SizedBox(width: 16),
              CircleAvatar(radius: 28, child: Text('RN')),
              SizedBox(width: 16),
              Expanded(
                child: Text('The tag is the link between the two screens.'),
              ),
            ],
          ),
        ),
        DemoCard(
          title: 'SliverAppBar',
          note: 'An app bar that shrinks as you scroll. Slivers live inside a '
              'CustomScrollView, never inside a plain ListView.',
          code: '''
CustomScrollView(
  slivers: [
    const SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(title: Text('Semester 5')),
    ),
    SliverList.builder(
      itemCount: 20,
      itemBuilder: (context, i) => ListTile(title: Text('Week \${i + 1}')),
    ),
  ],
)''',
          child: SizedBox(
            height: 240,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomScrollView(
                slivers: [
                  const SliverAppBar(
                    expandedHeight: 120,
                    pinned: true,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(title: Text('Semester 5')),
                  ),
                  SliverList.builder(
                    itemCount: 12,
                    itemBuilder: (context, i) =>
                        ListTile(dense: true, title: Text('Week ${i + 1}')),
                  ),
                ],
              ),
            ),
          ),
        ),
        DemoCard(
          title: 'DataTable',
          note: 'A real table with headers. Wrap it in a horizontal scroll view '
              'or it will overflow on a phone.',
          code: '''
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: DataTable(
    columns: const [DataColumn(label: Text('Course')), DataColumn(label: Text('Grade'))],
    rows: const [
      DataRow(cells: [DataCell(Text('App Dev')), DataCell(Text('A'))]),
    ],
  ),
)''',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Course')),
                DataColumn(label: Text('Credits'), numeric: true),
                DataColumn(label: Text('Grade')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('App Development')),
                  DataCell(Text('3')),
                  DataCell(Text('A')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Data Structures')),
                  DataCell(Text('4')),
                  DataCell(Text('B+')),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
