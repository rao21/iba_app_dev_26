import 'package:flutter/material.dart';

import '../data/todo_repository.dart';
import '../models/todo.dart';
import '../widgets/todo_tile.dart';

/// The whole CRUD screen. One Firestore collection ("todos"), four
/// operations: add, read (the live list), update (toggle/rename), delete.
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key, TodoRepository? repository})
      : _repository = repository;

  final TodoRepository? _repository;

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late final TodoRepository _repo = widget._repository ?? TodoRepository();

  Future<void> _addTodo() async {
    final title = await _promptForTitle(context, initial: '');
    if (title == null || title.trim().isEmpty) return;
    await _repo.add(title.trim());
  }

  Future<void> _renameTodo(Todo todo) async {
    final title = await _promptForTitle(context, initial: todo.title);
    if (title == null || title.trim().isEmpty) return;
    await _repo.rename(todo, title.trim());
  }

  Future<void> _deleteTodo(Todo todo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('"${todo.title}" will be removed for good.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _repo.remove(todo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: StreamBuilder<List<Todo>>(
        stream: _repo.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load tasks:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final todos = snapshot.data ?? const [];
          if (todos.isEmpty) {
            return const Center(child: Text('No tasks yet — tap + to add one'));
          }

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return TodoTile(
                todo: todo,
                onToggle: () => _repo.toggleDone(todo),
                onTap: () => _renameTodo(todo),
                onDelete: () => _deleteTodo(todo),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Shared by Add and Rename — same dialog, different starting text.
Future<String?> _promptForTitle(BuildContext context, {required String initial}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(initial.isEmpty ? 'New task' : 'Rename task'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'What needs doing?'),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
