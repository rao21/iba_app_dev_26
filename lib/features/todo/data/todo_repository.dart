import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/todo.dart';

class TodoRepository {
  TodoRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const _collectionPath = 'todos';

  CollectionReference<Map<String, dynamic>> get _todos =>
      _db.collection(_collectionPath);

  Future<void> add(String title) {
    return _todos.add({
      'title': title,
      'done': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Todo>> watchAll() {
    return _todos
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Todo.fromDoc).toList());
  }

  Future<void> toggleDone(Todo todo) {
    return _todos.doc(todo.id).update({'done': !todo.done});
  }

  Future<void> rename(Todo todo, String newTitle) {
    return _todos.doc(todo.id).update({'title': newTitle});
  }

  Future<void> remove(Todo todo) {
    return _todos.doc(todo.id).delete();
  }
}
