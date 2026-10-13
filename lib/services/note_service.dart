import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note_model.dart';

/// Every Firestore read and write for notes goes through this class.
/// Screens never call `FirebaseFirestore.instance` directly — they call
/// NoteService instead, so the Firestore collection name and query logic
/// live in exactly one place.
class NoteService {
  // The single collection this whole service talks to.
  final CollectionReference<Map<String, dynamic>> _notesRef =
      FirebaseFirestore.instance.collection('notes');

  /// CREATE — saves a brand-new note. Firestore generates the document id
  /// for us, which is why Note doesn't need an id until after this call.
  Future<void> addNote(Note note) async {
    await _notesRef.add(note.toMap());
  }

  /// READ — a live stream of every note, newest first. Because this is a
  /// Stream (not a one-time Future), the UI automatically redraws itself
  /// whenever a note is added, edited, or deleted — including changes made
  /// from another device.
  Stream<List<Note>> getNotes() {
    return _notesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Note.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// UPDATE — overwrites an existing note's fields by its document id.
  Future<void> updateNote(Note note) async {
    await _notesRef.doc(note.id).update(note.toMap());
  }

  /// DELETE — removes a note permanently by its document id.
  Future<void> deleteNote(String noteId) async {
    await _notesRef.doc(noteId).delete();
  }
}
