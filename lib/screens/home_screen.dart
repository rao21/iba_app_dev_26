import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note_model.dart';
import '../services/note_service.dart';
import 'note_form_screen.dart';

// The navy-to-blue gradient used on every AppBar in this app. Keeping it as
// a top-level constant means both screens stay visually identical without
// copy-pasting a Color list everywhere.
const _appBarGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
);

// Each note card's icon badge rotates through these accent colors, so a
// long list of notes doesn't read as one flat block of white cards.
const _accentColors = [
  Color(0xFF3B82F6), // blue
  Color(0xFF8B5CF6), // purple
  Color(0xFFF59E0B), // amber
  Color(0xFF10B981), // emerald
];

/// The notes list — the app's home screen. A StreamBuilder keeps it in
/// sync with Firestore in real time, and an optional search field filters
/// the already-loaded list locally.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteService _noteService = NoteService();
  final TextEditingController _searchController = TextEditingController();

  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Toggles the inline search field on and off, clearing any previous
  // search text so reopening search always starts fresh.
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  // Opens the shared add/edit form. Passing null means "add mode"; the
  // form screen itself decides its title and button label from this.
  void _openAddNoteForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteFormScreen(note: null)),
    );
  }

  void _openEditNoteForm(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteFormScreen(note: note)),
    );
  }

  // Shows a rounded confirmation dialog before actually deleting anything —
  // deleting a note is permanent, so it deserves a deliberate second tap.
  Future<void> _confirmDelete(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete this note?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _noteService.deleteNote(note.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: StreamBuilder<List<Note>>(
        stream: _noteService.getNotes(),
        builder: (context, snapshot) {
          final allNotes = snapshot.data ?? const <Note>[];

          // Local, client-side filter — the collection is small enough for a
          // teaching app that a second Firestore query isn't worth it.
          final notes = _searchQuery.isEmpty
              ? allNotes
              : allNotes
                  .where((n) =>
                      n.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();

          return CustomScrollView(
            slivers: [
              _buildAppBar(allNotes.length),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (notes.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(isSearch: _searchQuery.isNotEmpty),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  sliver: SliverList.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      // Cycle through the accent palette by index so
                      // neighbouring cards never land on the same colour.
                      final accent = _accentColors[index % _accentColors.length];
                      return _NoteCard(
                        note: note,
                        accentColor: accent,
                        onTap: () => _openEditNoteForm(note),
                        onDelete: () => _confirmDelete(note),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddNoteForm,
        backgroundColor: const Color(0xFF1D4ED8),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Note', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // A pinned, gradient SliverAppBar — its title swaps for a search field
  // when search mode is active, and its bottom row (subtitle/count or the
  // search field itself) stays visible while the list scrolls underneath.
  Widget _buildAppBar(int totalCount) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: const Color(0xFF0F172A),
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: _appBarGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _isSearching
                          ? _buildSearchField()
                          : const Text(
                              'My Notes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    // Circular search toggle button — switches between the
                    // magnifying glass and a close icon while active.
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _toggleSearch,
                        icon: Icon(
                          _isSearching ? Icons.close : Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!_isSearching) ...[
                  const SizedBox(height: 4),
                  Text(
                    '$totalCount ${totalCount == 1 ? 'note' : 'notes'}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Search notes...',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        border: InputBorder.none,
      ),
      onChanged: (value) => setState(() => _searchQuery = value),
    );
  }

  // The "nothing here" state: a muted icon plus a short, friendly message
  // instead of a blank white screen.
  Widget _buildEmptyState({required bool isSearch}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearch ? Icons.search_off_rounded : Icons.note_add_outlined,
              size: 72,
              color: Colors.blueGrey.shade200,
            ),
            const SizedBox(height: 16),
            Text(
              isSearch ? 'No matching notes' : 'No notes yet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSearch
                  ? 'Try a different search term.'
                  : 'Tap "New Note" below to write your first one.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}

/// One note, rendered as a custom shadowed card rather than a default
/// Material Card — rounded corners, a coloured icon badge, and a trailing
/// delete button.
class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.accentColor,
    required this.onTap,
    required this.onDelete,
  });

  final Note note;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The coloured icon badge — a rounded square, not a circle,
                // so it reads as a "document" rather than an avatar.
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.description_outlined, color: accentColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        note.description,
                        style: TextStyle(color: Colors.blueGrey.shade500, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('MMM d, yyyy • h:mm a').format(note.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey.shade300,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                  tooltip: 'Delete note',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
