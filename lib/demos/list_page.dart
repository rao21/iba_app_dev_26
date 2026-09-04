import 'package:flutter/material.dart';

import '../widgets/demo_card.dart';

/// Showing many things without typing many widgets.
class ListPage extends StatelessWidget {
  const ListPage({super.key});

  static const _courses = <(String, String)>[
    ('App Development', '3 credit hours'),
    ('Data Structures', '4 credit hours'),
    ('Database Systems', '3 credit hours'),
    ('Marketing Management', '3 credit hours'),
    ('Business Communication', '2 credit hours'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        DemoCard(
          title: 'ListView.builder',
          note: 'Builds only the rows near the screen. Ten thousand rows cost '
              'the same as ten.',
          code: '''
ListView.builder(
  itemCount: courses.length,
  itemBuilder: (context, i) => ListTile(
    leading: CircleAvatar(child: Text('\${i + 1}')),
    title: Text(courses[i].name),
    subtitle: Text(courses[i].credits),
  ),
)''',
          child: SizedBox(
            height: 240,
            child: ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, i) => ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(_courses[i].$1),
                subtitle: Text(_courses[i].$2),
              ),
            ),
          ),
        ),
        DemoCard(
          title: 'ListView.separated',
          note: 'Same idea, plus a widget drawn between every pair of rows.',
          code: '''
ListView.separated(
  itemCount: courses.length,
  separatorBuilder: (context, i) => const Divider(height: 1),
  itemBuilder: (context, i) => ListTile(title: Text(courses[i].name)),
)''',
          child: SizedBox(
            height: 200,
            child: ListView.separated(
              itemCount: _courses.length,
              separatorBuilder: (context, i) => const Divider(height: 1),
              itemBuilder: (context, i) => ListTile(
                dense: true,
                title: Text(_courses[i].$1),
              ),
            ),
          ),
        ),
        DemoCard(
          title: 'GridView.count',
          note: 'A list in columns. crossAxisCount is how many fit across.',
          code: '''
GridView.count(
  crossAxisCount: 3,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  children: [for (final c in courses) Card(child: Center(child: Text(c.name)))],
)''',
          child: SizedBox(
            height: 200,
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                for (final course in _courses)
                  Card(
                    margin: EdgeInsets.zero,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          course.$1,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const DemoCard(
          title: 'Unbounded height',
          note: 'A ListView inside a Column throws until you wrap it in '
              'Expanded — the Column offers infinite height, the ListView '
              'needs a finite one.',
          code: '''
// Throws: "Vertical viewport was given unbounded height".
Column(children: [Text('Courses'), ListView(children: rows)])

// Works.
Column(children: [Text('Courses'), Expanded(child: ListView(children: rows))])''',
          child: Swatch('wrap it in Expanded', height: 40),
        ),
      ],
    );
  }
}
