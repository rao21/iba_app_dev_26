import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  const Todo({
    required this.id,
    required this.title,
    required this.done,
  });

  final String id;
  final String title;
  final bool done;

  factory Todo.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Todo(
      id: doc.id,
      title: data['title'] as String,
      done: data['done'] as bool,
    );
  }

  // id is never sent — Firestore already knows it from the document path.
  Map<String, dynamic> toMap() => {'title': title, 'done': done};

  Todo copyWith({String? title, bool? done}) => Todo(
        id: id,
        title: title ?? this.title,
        done: done ?? this.done,
      );
}
