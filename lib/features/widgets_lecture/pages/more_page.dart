import 'package:flutter/material.dart';

import '../widgets/demo_card.dart';

/// Everyday widgets that don't fit neatly under Basics, Layout or Input, but
/// show up in almost every real screen.
class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  final _formKey = GlobalKey<FormState>();
  final _rollController = TextEditingController();
  String _attendance = 'present';
  int _taps = 0;
  int _page = 0;
  String _formResult = 'not submitted yet';

  @override
  void dispose() {
    _rollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        DemoCard(
          title: 'GestureDetector / InkWell',
          note: 'GestureDetector reacts to taps on any widget. InkWell does '
              'the same and adds the Material ripple.',
          code: '''
InkWell(
  onTap: () => setState(() => _taps++),
  borderRadius: BorderRadius.circular(8),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Text('Tapped \$_taps times'),
  ),
)''',
          child: Material(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => setState(() => _taps++),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Tapped $_taps times — tap anywhere on this card',
                  style: TextStyle(color: scheme.onSecondaryContainer),
                ),
              ),
            ),
          ),
        ),
        DemoCard(
          title: 'Form + TextFormField',
          note: 'Form groups fields under one key so you can validate all of '
              'them together with one call.',
          code: '''
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: TextFormField(
    controller: _rollController,
    decoration: const InputDecoration(labelText: 'Roll number'),
    validator: (value) => (value == null || value.length != 5)
        ? 'Roll number must be 5 digits'
        : null,
  ),
)

// elsewhere
if (_formKey.currentState!.validate()) { /* submit */ }''',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _rollController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Roll number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.length != 5)
                      ? 'Roll number must be 5 digits'
                      : null,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () {
                        final valid = _formKey.currentState!.validate();
                        setState(() {
                          _formResult = valid ? 'valid ✓' : 'invalid — fix it';
                        });
                      },
                      child: const Text('Validate'),
                    ),
                    const SizedBox(width: 12),
                    Text(_formResult),
                  ],
                ),
              ],
            ),
          ),
        ),
        DemoCard(
          title: 'RadioListTile',
          note: 'A group of radios that all share one value — only one can '
              'be selected.',
          code: '''
RadioGroup<String>(
  groupValue: _attendance,
  onChanged: (v) => setState(() => _attendance = v!),
  child: const Column(
    children: [
      RadioListTile<String>(title: Text('Present'), value: 'present'),
      RadioListTile<String>(title: Text('Absent'), value: 'absent'),
    ],
  ),
)''',
          child: RadioGroup<String>(
            groupValue: _attendance,
            onChanged: (v) => setState(() => _attendance = v ?? _attendance),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Present'),
                  value: 'present',
                ),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Absent'),
                  value: 'absent',
                ),
              ],
            ),
          ),
        ),
        DemoCard(
          title: 'PopupMenuButton',
          note: 'The ⋮ menu. Each item pops a value back to onSelected.',
          code: '''
PopupMenuButton<String>(
  onSelected: (value) => setState(() => _formResult = value),
  itemBuilder: (context) => const [
    PopupMenuItem(value: 'edit', child: Text('Edit')),
    PopupMenuItem(value: 'delete', child: Text('Delete')),
  ],
)''',
          child: Row(
            children: [
              PopupMenuButton<String>(
                onSelected: (value) => setState(() => _formResult = value),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
              const SizedBox(width: 8),
              Text('last selected: $_formResult'),
            ],
          ),
        ),
        const DemoCard(
          title: 'Tooltip + Badge',
          note: 'Tooltip explains an icon on long-press or hover. Badge marks '
              'a count on top of one.',
          code: '''
Badge(
  label: Text('3'),
  child: Tooltip(
    message: 'Unread announcements',
    child: Icon(Icons.notifications_outlined),
  ),
)''',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Badge(
                label: Text('3'),
                child: Tooltip(
                  message: 'Unread announcements',
                  child: Icon(Icons.notifications_outlined, size: 32),
                ),
              ),
            ],
          ),
        ),
        const DemoCard(
          title: 'ProgressIndicators',
          note: 'Circular for an unknown wait, linear for a known fraction '
              '(here, semester progress).',
          code: '''
const CircularProgressIndicator()
LinearProgressIndicator(value: 0.6)  // 60% of the semester done''',
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              LinearProgressIndicator(value: 0.6),
              SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Week 9 of 15'),
              ),
            ],
          ),
        ),
        DemoCard(
          title: 'PageView',
          note: 'Full-bleed swipeable pages — an onboarding flow, a story '
              'view.',
          code: '''
PageView(
  onPageChanged: (i) => setState(() => _page = i),
  children: const [Swatch('Page 1'), Swatch('Page 2'), Swatch('Page 3')],
)''',
          child: Column(
            children: [
              SizedBox(
                height: 90,
                child: PageView(
                  onPageChanged: (i) => setState(() => _page = i),
                  children: const [
                    Swatch('Page 1', height: 90),
                    Swatch('Page 2', height: 90),
                    Swatch('Page 3', height: 90),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 3; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _page ? scheme.primary : scheme.outlineVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const DemoCard(
          title: 'AspectRatio + ClipRRect',
          note: 'AspectRatio fixes width:height instead of a pixel size. '
              'ClipRRect rounds whatever is inside it, images included.',
          code: '''
AspectRatio(
  aspectRatio: 16 / 9,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.network(url, fit: BoxFit.cover),
  ),
)''',
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: ColoredBox(
                color: Color(0x332962FF),
                child: Center(child: Text('16 : 9')),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
