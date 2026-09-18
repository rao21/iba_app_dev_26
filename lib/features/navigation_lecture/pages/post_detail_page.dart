import 'package:flutter/material.dart';

import '../../../shared/widgets/http_badges.dart';
import '../../../shared/widgets/lecture_ui.dart';
import '../../api_lecture/models/comment.dart';
import '../../api_lecture/models/post.dart';
import '../../api_lecture/services/posts_api.dart';
import 'edit_title_page.dart';

/// The screen every technique on the previous page eventually lands on.
///
/// It only needs one thing to do its job: [postId]. Everything it shows —
/// the post, its comments, the ability to edit the title — it fetches or
/// builds for itself once it has that id. [initialTitle] is optional and
/// only saves the AppBar a moment of "loading…" when the caller already
/// had the title on hand (e.g. from the list it was shown in).
class PostDetailPage extends StatefulWidget {
  const PostDetailPage({
    super.key,
    required this.postId,
    this.initialTitle,
    PostsApi? api,
  }) : _api = api;

  final int postId;
  final String? initialTitle;
  final PostsApi? _api;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late final PostsApi _api = widget._api ?? PostsApi();
  late Future<ApiResponse<Post>> _postFuture;
  late Future<ApiResponse<List<Comment>>> _commentsFuture;
  String? _title;

  @override
  void initState() {
    super.initState();
    _title = widget.initialTitle;
    // Two independent requests, both keyed off the id we were handed.
    _postFuture = _api.fetchPost(widget.postId);
    _commentsFuture = _api.fetchComments(widget.postId);
  }

  Future<void> _editTitle() async {
    // Push and *wait*: this line does not move on until EditTitlePage pops.
    final newTitle = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => EditTitlePage(currentTitle: _title ?? ''),
      ),
    );

    // A cancelled edit pops with no value at all — nothing to do.
    if (newTitle == null || newTitle.isEmpty || !mounted) return;

    final response = await _api.updatePost(widget.postId, title: newTitle);
    if (!mounted) return;

    setState(() => _title = response.data.title);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved — PATCH returned ${response.statusCode}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title ?? 'Post #${widget.postId}'),
        actions: [
          IconButton(
            onPressed: _editTitle,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit title',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NoteBox(
            text: 'This screen only received one number — postId: '
                '${widget.postId}. Everything below was fetched using that '
                'number, after this screen had already opened.',
          ),
          const SizedBox(height: 16),
          FutureBuilder<ApiResponse<Post>>(
            future: _postFuture,
            builder: (context, snapshot) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RequestBar(
                    method: 'GET',
                    path: '/posts/${widget.postId}',
                    status: snapshot.data?.statusCode,
                  ),
                  const SizedBox(height: 12),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (snapshot.hasError)
                    Text('${snapshot.error}')
                  else
                    Text(
                      snapshot.data!.data.body,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                ],
              );
            },
          ),
          const SectionHeading(title: 'Comments — a second request, same id'),
          FutureBuilder<ApiResponse<List<Comment>>>(
            future: _commentsFuture,
            builder: (context, snapshot) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RequestBar(
                    method: 'GET',
                    path: '/posts/${widget.postId}/comments',
                    status: snapshot.data?.statusCode,
                  ),
                  const SizedBox(height: 12),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (snapshot.hasError)
                    Text('${snapshot.error}')
                  else
                    for (final comment in snapshot.data!.data.take(3))
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.comment_outlined),
                          title: Text(comment.name, maxLines: 1),
                          subtitle: Text(
                            comment.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
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
