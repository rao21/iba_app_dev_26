import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/posts_api.dart';
import '../widgets/api_widgets.dart';

/// Lecture 02: consuming a real REST API. GET renders a list through
/// FutureBuilder; POST adds to it and the new row is shown coming back from
/// the server, not just appended locally.
class ApiPage extends StatefulWidget {
  const ApiPage({super.key, PostsApi? api}) : _api = api;

  final PostsApi? _api;

  @override
  State<ApiPage> createState() => _ApiPageState();
}

class _ApiPageState extends State<ApiPage> {
  late final PostsApi _api = widget._api ?? PostsApi();
  late Future<ApiResponse<List<Post>>> _postsFuture;

  /// The id of a post that just arrived, so its row can be highlighted for a
  /// moment before fading back to normal.
  int? _justAddedId;

  @override
  void initState() {
    super.initState();
    // The request starts once, in initState — never inside build().
    _postsFuture = _api.fetchPosts();
  }

  Future<void> _refresh() async {
    final response = await _api.fetchPosts();
    if (!mounted) return;
    setState(() => _postsFuture = Future.value(response));
  }

  Future<void> _openComposer() async {
    final created = await showModalBottomSheet<Post>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ComposeSheet(api: _api),
    );

    if (created == null || !mounted) return;

    final current = await _postsFuture;
    if (!mounted) return;

    setState(() {
      _postsFuture = Future.value(
        ApiResponse(
          statusCode: current.statusCode,
          data: [created, ...current.data],
        ),
      );
      _justAddedId = created.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Server created post #${created.id}')),
    );

    // The highlight is a teaching cue, not permanent state — let it fade.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _justAddedId = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openComposer,
        icon: const Icon(Icons.add),
        label: const Text('New post'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            const LectureBanner(
              number: '02',
              title: 'Talking to an API',
              summary:
                  'Every request is a method plus an address. GET asks for '
                  'data; POST sends new data. The reply is a status code '
                  'plus a body — this screen shows both, live.',
            ),
            const SectionHeading(title: 'Reading a list — GET'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FutureBuilder<ApiResponse<List<Post>>>(
                future: _postsFuture,
                builder: (context, snapshot) {
                  final status = snapshot.data?.statusCode;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RequestBar(
                        method: 'GET',
                        path: '/posts',
                        status: status,
                      ),
                      const SizedBox(height: 12),
                      _GetBody(
                        snapshot: snapshot,
                        onRetry: _refresh,
                        highlightId: _justAddedId,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SectionHeading(title: 'Sending data — POST'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const MethodBadge('POST'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tap "New post" below — it opens a form, sends it, '
                        'and the reply lands at the top of the list above.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The body of the GET section: one branch per FutureBuilder state.
class _GetBody extends StatelessWidget {
  const _GetBody({
    required this.snapshot,
    required this.onRetry,
    required this.highlightId,
  });

  final AsyncSnapshot<ApiResponse<List<Post>>> snapshot;
  final Future<void> Function() onRetry;

  /// The post that just came back from a POST — its row gets a brief tint
  /// so "the reply landed at the top of the list" is visible, not just true.
  final int? highlightId;

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (snapshot.hasError) {
      return _ErrorState(message: '${snapshot.error}', onRetry: onRetry);
    }

    final posts = snapshot.data!.data;
    return Column(
      children: [
        for (final post in posts)
          _PostCard(post: post, highlighted: post.id == highlightId),
      ],
    );
  }
}

/// One row in the list. [highlighted] briefly tints a post that just arrived
/// from a POST, so the round trip reads as "this one just came back",
/// not just another row that was always there.
class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.highlighted});

  final Post post;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: highlighted ? scheme.tertiaryContainer : scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlighted ? scheme.tertiary : scheme.outlineVariant,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: scheme.secondaryContainer,
          child: Text('${post.id}'),
        ),
        title: Text(
          post.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          post.body,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            highlighted ? Icon(Icons.fiber_new, color: scheme.tertiary) : null,
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
  Future<ApiResponse<Post>>? _submission;

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
          Row(
            children: [
              const MethodBadge('POST'),
              const SizedBox(width: 10),
              Text('New post', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
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
            FutureBuilder<ApiResponse<Post>>(
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
                    onRetry: () async =>
                        setState(() => _submission = null),
                  );
                }

                final response = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RequestBar(
                      method: 'POST',
                      path: '/posts',
                      status: response.statusCode,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Server assigned id ${response.data.id}'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, response.data),
                      child: const Text('Add to list'),
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
  final Future<void> Function() onRetry;

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
