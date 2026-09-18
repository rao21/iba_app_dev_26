import 'package:flutter/material.dart';

import '../widgets/demo_card.dart';

/// Widgets that take input. Every one of them needs a State to hold the value,
/// which is why this whole page is a StatefulWidget.
class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _nameController = TextEditingController();
  bool _notify = true;
  bool _agreed = false;
  double _credits = 12;
  String _campus = 'Main';
  String _lastAction = 'nothing yet';

  @override
  void dispose() {
    // Controllers hold resources. Always release them here.
    _nameController.dispose();
    super.dispose();
  }

  void _record(String action) => setState(() => _lastAction = action);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        DemoCard(
          title: 'Buttons',
          note: 'onPressed: null renders the button disabled — that is the API.',
          code: '''
ElevatedButton(onPressed: () {}, child: const Text('Submit'))
FilledButton(onPressed: () {}, child: const Text('Enroll'))
OutlinedButton(onPressed: () {}, child: const Text('Cancel'))
TextButton(onPressed: null, child: const Text('Disabled'))''',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => _record('Submit pressed'),
                child: const Text('Submit'),
              ),
              FilledButton(
                onPressed: () => _record('Enroll pressed'),
                child: const Text('Enroll'),
              ),
              OutlinedButton(
                onPressed: () => _record('Cancel pressed'),
                child: const Text('Cancel'),
              ),
              const TextButton(onPressed: null, child: Text('Disabled')),
              IconButton(
                onPressed: () => _record('Icon pressed'),
                icon: const Icon(Icons.bookmark_border),
              ),
            ],
          ),
        ),
        DemoCard(
          title: 'TextField',
          note: 'The text lives in a TextEditingController, not in the widget.',
          code: '''
TextField(
  controller: _nameController,
  decoration: const InputDecoration(
    labelText: 'Full name',
    border: OutlineInputBorder(),
  ),
  onChanged: (value) => setState(() {}),
)''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Text(
                _nameController.text.isEmpty
                    ? 'Type above and this line rebuilds.'
                    : 'Hello, ${_nameController.text}',
              ),
            ],
          ),
        ),
        DemoCard(
          title: 'Switch, Checkbox, Slider',
          note: 'Each one reports a new value; you store it and call setState.',
          code: '''
Switch(value: _notify, onChanged: (v) => setState(() => _notify = v))
Checkbox(value: _agreed, onChanged: (v) => setState(() => _agreed = v ?? false))
Slider(
  value: _credits,
  min: 0,
  max: 21,
  divisions: 7,
  label: '\${_credits.round()} credits',
  onChanged: (v) => setState(() => _credits = v),
)''',
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Class notifications'),
                value: _notify,
                onChanged: (v) => setState(() => _notify = v),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('I have read the course policy'),
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
              ),
              Slider(
                value: _credits,
                min: 0,
                max: 21,
                divisions: 7,
                label: '${_credits.round()} credits',
                onChanged: (v) => setState(() => _credits = v),
              ),
              Text('Registered for ${_credits.round()} credit hours'),
            ],
          ),
        ),
        DemoCard(
          title: 'DropdownButton',
          note: 'A value plus the list of values it is allowed to take.',
          code: '''
DropdownButton<String>(
  value: _campus,
  items: const [
    DropdownMenuItem(value: 'Main', child: Text('Main Campus')),
    DropdownMenuItem(value: 'City', child: Text('City Campus')),
  ],
  onChanged: (v) => setState(() => _campus = v!),
)''',
          child: DropdownButton<String>(
            value: _campus,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'Main', child: Text('Main Campus')),
              DropdownMenuItem(value: 'City', child: Text('City Campus')),
            ],
            onChanged: (v) => setState(() => _campus = v ?? _campus),
          ),
        ),
        DemoCard(
          title: 'SnackBar',
          note: 'Feedback after an action. Needs a Scaffold above it in the tree.',
          code: '''
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Saved')),
)''',
          child: Row(
            children: [
              FilledButton.tonal(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved')),
                  );
                  _record('SnackBar shown');
                },
                child: const Text('Save'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Last action: $_lastAction',
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
