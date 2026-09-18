import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/http_badges.dart';
import '../../../shared/widgets/lecture_ui.dart';
import '../../api_lecture/models/post.dart';
import '../../api_lecture/services/posts_api.dart';

/// A tiny, self-contained app-inside-the-app, so students can compare
/// go_router directly against the Navigator.push/pop just shown, without
/// touching how the rest of this gallery navigates.
///
/// Everything here runs inside its own [MaterialApp.router] — its own
/// Navigator, its own route stack — and that whole thing is what got pushed
/// onto the *outer* app's stack. To leave it for good, the exit button below
/// reaches for the outer Navigator explicitly.
class GoRouterDemoPage extends StatelessWidget {
  const GoRouterDemoPage({super.key, PostsApi? api}) : _api = api;

  final PostsApi? _api;

  @override
  Widget build(BuildContext context) {
    final api = _api ?? PostsApi();
    final theme = Theme.of(context);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => _GoListScreen(api: api),
        ),
        GoRoute(
          // :id is a path parameter — go_router reads it out of the URL
          // itself, so "the address" and "the data it carries" are the
          // same string. Visit /post/3 and id is '3', no arguments object
          // involved.
          path: '/post/:id',
          builder: (context, state) => _GoDetailScreen(
            api: api,
            postId: int.parse(state.pathParameters['id']!),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      theme: theme,
      debugShowCheckedModeBanner: false,
    );
  }
}

class _GoListScreen extends StatelessWidget {
  const _GoListScreen({required this.api});

  final PostsApi api;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('go_router demo · "/"'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Exit demo',
          // rootNavigator: true skips this mini app's own Navigator and
          // pops the *outer* app's route instead — the only way out, since
          // there is no "/" to go back to from here.
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const NoteBox(
            text: 'No Navigator.push here. Tapping a post changes the URL '
                "to /post/<id>, and go_router decides what that means.",
          ),
          const SizedBox(height: 12),
          FutureBuilder<ApiResponse<List<Post>>>(
            future: api.fetchPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) return Text('${snapshot.error}');

              return Column(
                children: [
                  for (final post in snapshot.data!.data.take(8))
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${post.id}')),
                        title: Text(post.title, maxLines: 1),
                        trailing: const Icon(Icons.chevron_right),
                        // The declarative move: hand go_router a path, not
                        // a screen. It looks up '/post/:id' and builds it.
                        onTap: () => context.push('/post/${post.id}'),
                      ),
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

class _GoDetailScreen extends StatelessWidget {
  const _GoDetailScreen({required this.api, required this.postId});

  final PostsApi api;
  final int postId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('go_router demo · /post/$postId'),
        // context.pop() here pops *this mini app's* stack, back to '/' —
        // a normal back button, same idea as Navigator.pop, spelled the
        // go_router way.
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NoteBox(
              text: "The '$postId' above came from the URL itself — "
                  "state.pathParameters['id']. Nothing was passed through "
                  'a constructor.',
            ),
            const SizedBox(height: 16),
            FutureBuilder<ApiResponse<Post>>(
              future: api.fetchPost(postId),
              builder: (context, snapshot) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RequestBar(
                      method: 'GET',
                      path: '/posts/$postId',
                      status: snapshot.data?.statusCode,
                    ),
                    const SizedBox(height: 12),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator())
                    else if (snapshot.hasError)
                      Text('${snapshot.error}')
                    else
                      Text(snapshot.data!.data.body),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
