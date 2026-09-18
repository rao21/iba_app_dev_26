import 'package:flutter/material.dart';

import '../../../shared/widgets/code_block.dart';
import '../../../shared/widgets/lecture_ui.dart';
import '../../api_lecture/models/post.dart';
import '../../api_lecture/services/posts_api.dart';
import 'go_router_demo_page.dart';
import 'post_detail_page.dart';

/// Lecture 03: Navigation & Routing.
///
/// Everything on this page is one use case, told three ways: tap a post to
/// open it. First with an imperative push, then with a named route, then —
/// as an intro only — the declarative style most new Flutter apps reach for.
class RoutingLecturePage extends StatefulWidget {
  const RoutingLecturePage({super.key, PostsApi? api}) : _api = api;

  /// The named route this page registers itself under. main.dart reads
  /// this constant instead of the string being typed twice.
  static const routeName = '/post-detail';

  final PostsApi? _api;

  @override
  State<RoutingLecturePage> createState() => _RoutingLecturePageState();
}

class _RoutingLecturePageState extends State<RoutingLecturePage> {
  late final PostsApi _api = widget._api ?? PostsApi();
  late final Future<ApiResponse<List<Post>>> _postsFuture = _api.fetchPosts();

  void _pushDirect(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(
          postId: post.id,
          initialTitle: post.title,
          api: _api,
        ),
      ),
    );
  }

  void _pushNamed(Post post) {
    // The id is the whole "arguments" object here — it could just as
    // easily be a small class if a screen needed more than one value.
    Navigator.pushNamed(context, RoutingLecturePage.routeName, arguments: post.id);
  }

  void _openGoRouterDemo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GoRouterDemoPage(api: _api)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const LectureBanner(
            number: '03',
            title: 'Navigation & Routing',
            summary:
                'Screens sit on a stack. Push adds one on top, pop removes '
                'it. "Passing data" just means: what goes in when you push, '
                'and what comes out when you pop.',
          ),

          const SectionHeading(title: 'The stack, in one picture'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _StackDiagram(),
          ),

          const SectionHeading(title: '1 · Navigator.push — sending data forward'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const NoteBox(
                  text: 'Tap a title below to build the next screen '
                      "yourself and hand it what it needs — a postId and, "
                      'if we already have it, a title — through its '
                      'constructor, exactly like passing a value to any '
                      'Dart class.',
                ),
                const SizedBox(height: 8),
                const CodeBlock(
                  code: '''
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PostDetailPage(
      postId: post.id,
      initialTitle: post.title,
    ),
  ),
);''',
                ),
              ],
            ),
          ),

          const SectionHeading(title: '2 · Named routes — the same trip, by address'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const NoteBox(
                  text: 'Use the "named" button on a row instead, and the '
                      'app looks up which screen answers to that address '
                      "in one place (onGenerateRoute in main.dart) — the "
                      'screen itself never has to be built by hand at the '
                      'call site.',
                ),
                const SizedBox(height: 8),
                const CodeBlock(
                  code: '''
// registered once, in MaterialApp
onGenerateRoute: (settings) {
  if (settings.name == '/post-detail') {
    final postId = settings.arguments as int;
    return MaterialPageRoute(
      builder: (context) => PostDetailPage(postId: postId),
    );
  }
  return null;
}

// used from anywhere
Navigator.pushNamed(context, '/post-detail', arguments: post.id);''',
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FutureBuilder<ApiResponse<List<Post>>>(
              future: _postsFuture,
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
                          title: Text(
                            post.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _pushDirect(post),
                          trailing: TextButton(
                            onPressed: () => _pushNamed(post),
                            child: const Text('named'),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          const SectionHeading(title: '3 · Returning data — the trip back'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NoteBox(
                  text: 'Open any post above, then tap the pencil icon. '
                      'The edit screen only collects a new title and pops '
                      'it back — the detail screen decides what to do with '
                      'it, including calling the API to save it.',
                ),
                SizedBox(height: 8),
                CodeBlock(
                  code: '''
final newTitle = await Navigator.push<String>(
  context,
  MaterialPageRoute(builder: (context) => EditTitlePage(currentTitle: title)),
);

if (newTitle != null) {
  await api.updatePost(postId, title: newTitle);
}''',
                ),
              ],
            ),
          ),

          const SectionHeading(title: '4 · Intro to Navigator 2.0 — go_router'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const NoteBox(
                  text: 'Everything above is Navigator 1.0: imperative — '
                      'your code decides exactly when to push and pop. '
                      'go_router is declarative: you describe routes as '
                      'URL paths, and it works out the stack from the '
                      'address, the way a website does.',
                ),
                const SizedBox(height: 8),
                const CodeBlock(
                  code: '''
final router = GoRouter(routes: [
  GoRoute(path: '/', builder: (context, state) => const PostListScreen()),
  GoRoute(
    path: '/post/:id',
    builder: (context, state) {
      final id = int.parse(state.pathParameters['id']!);
      return PostDetailScreen(postId: id);
    },
  ),
]);

// navigating changes the URL instead of building a screen directly
context.push('/post/\${post.id}');''',
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _openGoRouterDemo,
                  icon: const Icon(Icons.alt_route),
                  label: const Text('Open the go_router demo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Three boxes and two arrows — the entire mental model this lecture is
/// teaching, before a single line of code.
class _StackDiagram extends StatelessWidget {
  const _StackDiagram();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget box(String label) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSecondaryContainer, fontSize: 12.5),
            ),
          ),
        );

    Widget arrow(String label) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_forward, size: 16),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            box('Post list'),
            arrow('push'),
            box('Post detail'),
            arrow('push'),
            box('Edit title'),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'pop() removes whatever is on top — Edit title first, then Post '
          'detail, then back to the list.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
