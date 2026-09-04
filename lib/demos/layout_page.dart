import 'package:flutter/material.dart';

import '../widgets/demo_card.dart';

/// Widgets that draw nothing themselves and exist only to position children.
class LayoutPage extends StatelessWidget {
  const LayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: const [
        DemoCard(
          title: 'Column',
          note: 'Children top to bottom. Its main axis is vertical.',
          code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [Swatch('A'), SizedBox(height: 8), Swatch('B')],
)''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Swatch('A'),
              SizedBox(height: 8),
              Swatch('B'),
            ],
          ),
        ),
        DemoCard(
          title: 'Row + mainAxisAlignment',
          note: 'Children left to right. spaceBetween pushes them to the edges.',
          code: '''
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [Swatch('A'), Swatch('B'), Swatch('C')],
)''',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Swatch('A'), Swatch('B'), Swatch('C')],
          ),
        ),
        DemoCard(
          title: 'Expanded',
          note: 'Shares the leftover space. flex: 2 takes twice as much as flex: 1.',
          code: '''
Row(
  children: [
    Expanded(flex: 2, child: Swatch('flex: 2')),
    SizedBox(width: 8),
    Expanded(child: Swatch('flex: 1')),
  ],
)''',
          child: Row(
            children: [
              Expanded(flex: 2, child: Swatch('flex: 2')),
              SizedBox(width: 8),
              Expanded(child: Swatch('flex: 1')),
            ],
          ),
        ),
        DemoCard(
          title: 'Stack + Positioned',
          note: 'Layers children. Later children sit on top of earlier ones.',
          code: '''
Stack(
  children: [
    Swatch('background', height: 100),
    Positioned(
      right: 8,
      bottom: 8,
      child: CircleAvatar(radius: 18, child: Text('9+')),
    ),
  ],
)''',
          child: Stack(
            children: [
              Swatch('background', height: 100),
              Positioned(
                right: 8,
                bottom: 8,
                child: CircleAvatar(radius: 18, child: Text('9+')),
              ),
            ],
          ),
        ),
        DemoCard(
          title: 'Padding vs SizedBox',
          note: 'Padding pushes a child inwards. SizedBox is an empty gap.',
          code: '''
Padding(
  padding: EdgeInsets.all(16),
  child: Swatch('padded by 16'),
)''',
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color(0x11000000)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Swatch('padded by 16'),
            ),
          ),
        ),
        DemoCard(
          title: 'Wrap',
          note: 'Like a Row that moves to the next line instead of overflowing.',
          code: '''
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [for (final t in tags) Chip(label: Text(t))],
)''',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Dart')),
              Chip(label: Text('Widgets')),
              Chip(label: Text('Layout')),
              Chip(label: Text('State')),
              Chip(label: Text('Navigation')),
              Chip(label: Text('Testing')),
            ],
          ),
        ),
        DemoCard(
          title: 'RenderFlex overflow',
          note: 'The yellow tape means a child asked for more room than it got. '
              'Wrap the greedy child in Expanded to fix it.',
          code: '''
// Overflows: three fixed boxes wider than the screen.
Row(children: [Swatch('wide'), Swatch('wide'), Swatch('wide')])

// Fixed: each child takes an equal share of what exists.
Row(children: [
  Expanded(child: Swatch('wide')),
  Expanded(child: Swatch('wide')),
  Expanded(child: Swatch('wide')),
])''',
          child: Row(
            children: [
              Expanded(child: Swatch('wide')),
              SizedBox(width: 8),
              Expanded(child: Swatch('wide')),
              SizedBox(width: 8),
              Expanded(child: Swatch('wide')),
            ],
          ),
        ),
      ],
    );
  }
}
