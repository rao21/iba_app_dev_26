import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post.dart';

/// Talks to JSONPlaceholder. Takes an [http.Client] instead of creating one,
/// so a test can hand it a fake client instead of hitting the real network.
class PostsApi {
  PostsApi({http.Client? client}) : _client = client ?? http.Client();

  static final _base = Uri.parse('https://jsonplaceholder.typicode.com/posts');

  final http.Client _client;

  /// GET /posts — the list every FutureBuilder in this lecture renders.
  Future<List<Post>> fetchPosts() async {
    final response = await _client.get(_base);

    if (response.statusCode != 200) {
      throw Exception('GET /posts failed: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    return body
        .cast<Map<String, dynamic>>()
        .map(Post.fromJson)
        .take(15) // the real endpoint returns 100 — plenty for a demo list
        .toList();
  }

  /// POST /posts. JSONPlaceholder doesn't really save it, but it echoes the
  /// body back with a fake id (101), which is enough to show the round trip.
  Future<Post> createPost({required String title, required String body}) async {
    final response = await _client.post(
      _base,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'userId': 1, 'title': title, 'body': body}),
    );

    if (response.statusCode != 201) {
      throw Exception('POST /posts failed: ${response.statusCode}');
    }

    return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
