import 'package:flutter/material.dart';

import '../models/note_model.dart';
import '../services/note_service.dart';

// Shared with home_screen.dart's AppBar so both screens look like the same
// app — a lecture codebase keeps this small duplication instead of pulling
// in a separate theme file for a two-screen app.
const _appBarGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
);

/// The add/edit form. One screen handles both jobs: pass [note] as null to
/// add a new note, or pass an existing Note to edit it. The screen reads
/// its own title, button label, and starting field values from whichever
/// case applies.
class NoteFormScreen extends StatefulWidget {
  const NoteFormScreen({super.key, required this.note});

  /// Null means "creating a new note". A non-null value means "editing
  /// this note" — its id is reused when saving.
  final Note? note;

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final NoteService _noteService = NoteService();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  bool _isSaving = false;

  // true once widget.note is non-null — read once here instead of
  // re-checking `widget.note == null` throughout build().
  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill the fields when editing; start blank when adding.
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.note?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Validates the form, then either adds a new note or updates the
  // existing one, shows a confirmation, and returns to the list.
  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    try {
      if (_isEditing) {
        final updated = widget.note!.copyWith(title: title, description: description);
        await _noteService.updateNote(updated);
      } else {
        final newNote = Note(
          id: '', // Firestore assigns the real id inside addNote().
          title: title,
          description: description,
          createdAt: DateTime.now(),
        );
        await _noteService.addNote(newNote);
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Note updated' : 'Note added'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Without this, a rejected write (e.g. Firestore security rules
      // blocking it) fails silently — the screen just sits there with no
      // feedback. Showing the real error makes that failure visible.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save note: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      // Only matters if saving failed and the screen is still open —
      // on success the screen has already been popped above.
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: _appBarGradient)),
        title: Text(_isEditing ? 'Edit Note' : 'Add Note'),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildStyledField(
              controller: _titleController,
              label: 'Title',
              icon: Icons.title_rounded,
              maxLines: 1,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            _buildStyledField(
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.notes_rounded,
              maxLines: 6,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please enter a description'
                  : null,
            ),
            const SizedBox(height: 28),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // A filled, rounded text field with a leading icon — used for both the
  // title and description inputs so they look like one form, not two
  // differently-styled widgets glued together.
  Widget _buildStyledField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required int maxLines,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 80 : 0),
          child: Icon(icon, color: const Color(0xFF1D4ED8)),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  // The gradient Save/Update button. While _isSaving is true it shows a
  // spinner instead of its label and icon, and disables the tap handler so
  // a slow connection can't trigger a second save.
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _appBarGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _isSaving ? null : _saveNote,
            child: Center(
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_rounded, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          _isEditing ? 'Update' : 'Save',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
