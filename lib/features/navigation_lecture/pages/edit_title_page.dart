import 'package:flutter/material.dart';

import '../../../shared/widgets/lecture_ui.dart';

/// A screen with exactly one job: collect a new title and hand it back.
///
/// It never talks to the API and never hears about post ids — that is the
/// point of this example. Whoever pushed this screen decides what to do
/// with the text it returns; this screen only returns it.
class EditTitlePage extends StatefulWidget {
  const EditTitlePage({super.key, required this.currentTitle});

  final String currentTitle;

  @override
  State<EditTitlePage> createState() => _EditTitlePageState();
}

class _EditTitlePageState extends State<EditTitlePage> {
  late final _controller = TextEditingController(text: widget.currentTitle);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    // Navigator.pop's second argument is the result. Whatever screen called
    // Navigator.push to get here receives exactly this value back.
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit title'),
        // Popping with no argument (the default back button) sends null —
        // the caller can tell "cancelled" apart from "saved".
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NoteBox(
              text: 'This screen only collects text and pops it back. It '
                  "does not know a post id exists — that's the previous "
                  "screen's job.",
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Save and go back'),
            ),
          ],
        ),
      ),
    );
  }
}
