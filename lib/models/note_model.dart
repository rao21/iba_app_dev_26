import 'package:cloud_firestore/cloud_firestore.dart';

/// A single note stored in the "notes" Firestore collection.
///
/// [id] is the Firestore document id. It is empty for a note that has not
/// been saved yet (e.g. while filling out the "Add Note" form), and gets
/// filled in once NoteService hands back a saved document.
class Note {
  const Note({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  /// Converts a Firestore document into a Note. [id] comes from the
  /// document's own path, not its data, so it is passed in separately.
  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      // Firestore stores dates as Timestamp, not DateTime — convert here so
      // the rest of the app only ever deals in plain DateTime.
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this Note into the plain map Firestore expects. The id is
  /// deliberately left out — Firestore already knows it from the document
  /// path, and writing it into the data too would just be duplication.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Returns a copy of this note with the given fields replaced — handy for
  /// building the updated version of a note in the edit form.
  Note copyWith({String? title, String? description}) {
    return Note(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
    );
  }
}
