import 'package:flutter/material.dart';

import '../widgets/demo_card.dart';

/// Widgets that move the user somewhere, or put something on top of the page:
/// drawers, sheets, dialogs, tabs and routes.
class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        DemoCard(
          title: 'Drawer',
          note: 'A panel that slides in from the side. It is a property of '
              'Scaffold, not something you push. Open the app drawer from the '
              'menu button in the app bar to see the real one.',
          code: '''
Scaffold(
  drawer: Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(child: Text('IBA App Dev')),
        ListTile(
          leading: Icon(Icons.dashboard),
          title: Text('Layout'),
          onTap: () => Navigator.pop(context),
        ),
      ],
    ),
  ),
  // endDrawer: Drawer(...)  // the same thing, from the right
  body: ...,
)''',
          child: _MiniScaffold(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Drawer demo'),
                automaticallyImplyLeading: true,
              ),
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: const Align(
                        alignment: Alignment.bottomLeft,
                        child: Text('IBA App Dev'),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Profile'),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('Settings'),
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              body: const Center(child: Text('Tap the ☰ button')),
            ),
          ),
        ),
        DemoCard(
          title: 'showModalBottomSheet',
          note: 'A sheet from the bottom. Returns a Future that completes with '
              'whatever you pop.',
          code: '''
final choice = await showModalBottomSheet<String>(
  context: context,
  showDragHandle: true,
  builder: (context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(
        leading: const Icon(Icons.share),
        title: const Text('Share'),
        onTap: () => Navigator.pop(context, 'share'),
      ),
    ],
  ),
);''',
          child: _ActionRow(
            label: 'Open sheet',
            run: (context) async {
              final choice = await showModalBottomSheet<String>(
                context: context,
                showDragHandle: true,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.share_outlined),
                      title: const Text('Share'),
                      onTap: () => Navigator.pop(context, 'share'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: const Text('Download'),
                      onTap: () => Navigator.pop(context, 'download'),
                    ),
                  ],
                ),
              );
              return choice ?? 'dismissed';
            },
          ),
        ),
        DemoCard(
          title: 'AlertDialog',
          note: 'Blocks until the user answers. Pop a value to know which '
              'button they chose.',
          code: '''
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Drop this course?'),
    content: const Text('You can re-enroll until the add/drop deadline.'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Drop'),
      ),
    ],
  ),
);''',
          child: _ActionRow(
            label: 'Open dialog',
            run: (context) async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Drop this course?'),
                  content: const Text(
                    'You can re-enroll until the add/drop deadline.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Drop'),
                    ),
                  ],
                ),
              );
              return confirmed == true ? 'dropped' : 'kept';
            },
          ),
        ),
        DemoCard(
          title: 'TabBar + TabBarView',
          note: 'Both need a TabController above them. DefaultTabController is '
              'the one-line way to supply it.',
          code: '''
DefaultTabController(
  length: 3,
  child: Column(
    children: [
      const TabBar(tabs: [Tab(text: 'Mon'), Tab(text: 'Tue'), Tab(text: 'Wed')]),
      const Expanded(
        child: TabBarView(children: [DayView(0), DayView(1), DayView(2)]),
      ),
    ],
  ),
)''',
          child: SizedBox(
            height: 160,
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [Tab(text: 'Mon'), Tab(text: 'Tue'), Tab(text: 'Wed')],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        for (final day in ['Monday', 'Tuesday', 'Wednesday'])
                          Center(child: Text('$day timetable')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DemoCard(
          title: 'Navigator.push',
          note: 'Puts a whole new screen on the stack. pop() takes it off and '
              'can hand a value back to whoever pushed it.',
          code: '''
final picked = await Navigator.push<String>(
  context,
  MaterialPageRoute(builder: (context) => const CoursePickerPage()),
);

// inside CoursePickerPage
Navigator.pop(context, 'Data Structures');''',
          child: _ActionRow(
            label: 'Open a screen',
            run: (context) async {
              final picked = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (context) => const _PickerPage()),
              );
              return picked ?? 'came back empty';
            },
          ),
        ),
      ],
    );
  }
}

/// A full second screen, pushed by the Navigator demo.
class _PickerPage extends StatelessWidget {
  const _PickerPage();

  static const _courses = ['App Development', 'Data Structures', 'Marketing'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick a course')),
      body: ListView(
        children: [
          for (final course in _courses)
            ListTile(
              title: Text(course),
              onTap: () => Navigator.pop(context, course),
            ),
        ],
      ),
    );
  }
}

/// Runs an async action and prints whatever it returned, so the class can see
/// that dialogs and sheets hand a value back.
class _ActionRow extends StatefulWidget {
  const _ActionRow({required this.label, required this.run});

  final String label;
  final Future<String> Function(BuildContext context) run;

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  String _result = 'no result yet';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilledButton.tonal(
          onPressed: () async {
            final result = await widget.run(context);
            if (!mounted) return; // the demo may have been scrolled away
            setState(() => _result = result);
          },
          child: Text(widget.label),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'returned: $_result',
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// A small framed Scaffold so a demo can own an app bar and a drawer without
/// taking over the whole page.
class _MiniScaffold extends StatelessWidget {
  const _MiniScaffold({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 220,
        child: Builder(builder: builder),
      ),
    );
  }
}
