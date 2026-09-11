import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/posts_api.dart';
import '../widgets/demo_card.dart';

/// The API lecture: a real GET request rendered with FutureBuilder, and a
/// real POST request that adds to the list once it comes back.
class ApiPage extends StatefulWidget {
  const ApiPage({super.key, PostsApi? api}) : _api = api;

  final PostsApi? _api;

  @override
  State<ApiPage> createState() => _ApiPageState();
}

class _ApiPageState extends State<ApiPage> {
  late final PostsApi _api = widget._api ?? PostsApi();
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    // The request starts once, in initState — never inside build().
    _postsFuture = _api.fetchPosts();
  }

  void _refresh() {
    setState(() => _postsFuture = _api.fetchPosts());
  }

  Future<void> _openComposer() async {
    final created = await showModalBottomSheet<Post>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ComposeSheet(api: _api),
    );

    if (created == null || !mounted) return;

    // Prepend the freshly-posted item so the round trip is visible without
    // waiting on a second GET.
    setState(() {
      _postsFuture = _postsFuture.then((posts) => [created, ...posts]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openComposer,
        icon: const Icon(Icons.add),
        label: const Text('POST'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          DemoCard(
            title: 'GET — a list from the network',
            note: 'FutureBuilder rebuilds around whatever state the Future is '
                'in right now: waiting, error, or data. Handle all three.',
            code: '''
Future<List<Post>> _postsFuture = api.fetchPosts();

FutureBuilder<List<Post>>(
  future: _postsFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Something went wrong: \${snapshot.error}');
    }
    final posts = snapshot.data!;
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, i) => ListTile(title: Text(posts[i].title)),
    );
  },
)''',
            child: SizedBox(
              height: 340,
              child: FutureBuilder<List<Post>>(
                future: _postsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _ErrorState(
                      message: '${snapshot.error}',
                      onRetry: _refresh,
                    );
                  }

                  final posts = snapshot.data ?? const [];
                  return ListView.separated(
                    itemCount: posts.length,
                    separatorBuilder: (context, i) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final post = posts[i];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${post.id}')),
                        title: Text(
                          post.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          post.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Fetch again'),
            ),
          ),
          const DemoCard(
            title: 'POST — sending data back',
            note: 'Tap the POST button below the list. JSONPlaceholder is a '
                'fake API: it does not really save the post, but it echoes it '
                'back with a new id, which is enough to see the whole round '
                'trip — request, wait, response.',
            code: '''
Future<Post> createPost({required String title, required String body}) async {
  final response = await client.post(
    Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode({'userId': 1, 'title': title, 'body': body}),
  );

  if (response.statusCode != 201) {
    throw Exception('POST /posts failed: \${response.statusCode}');
  }
  return Post.fromJson(jsonDecode(response.body));
}''',
            child: Swatch('tap the POST button, bottom right', height: 40),
          ),
        ],
      ),
    );
  }
}

/// The bottom sheet a POST is composed in — its own StatefulWidget so typing
/// in the fields doesn't rebuild the list behind it.
class _ComposeSheet extends StatefulWidget {
  const _ComposeSheet({required this.api});

  final PostsApi api;

  @override
  State<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<_ComposeSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  Future<Post>? _submission;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    setState(() {
      _submission = widget.api.createPost(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New post', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Body',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (_submission == null)
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send),
              label: const Text('POST /posts'),
            )
          else
            FutureBuilder<Post>(
              future: _submission,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _ErrorState(
                    message: '${snapshot.error}',
                    onRetry: () => setState(() => _submission = null),
                  );
                }

                final post = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Server assigned id ${post.id}'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, post),
                      child: const Text('Done'),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Shared by both FutureBuilders on this page — a network call failed, and
/// the only sensible move is to let the user try it again.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 32),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
