import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/comment.dart';
import '../models/post.dart';

/// A response paired with the status code it came back with — the two things
/// every HTTP call actually hands you, and the point of Lecture 02.
class ApiResponse<T> {
  const ApiResponse({required this.statusCode, required this.data});

  final int statusCode;
  final T data;
}

/// Talks to JSONPlaceholder. Takes an [http.Client] instead of creating one,
/// so a test can hand it a fake client instead of hitting the real network.
class PostsApi {
  PostsApi({http.Client? client}) : _client = client ?? http.Client();

  static final _base = Uri.parse('https://jsonplaceholder.typicode.com/posts');

  final http.Client _client;

  /// GET /posts — the list every FutureBuilder in this lecture renders.
  Future<ApiResponse<List<Post>>> fetchPosts() async {
    final response = await _client.get(_base);

    if (response.statusCode != 200) {
      throw Exception('GET /posts failed: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    final posts = body
        .cast<Map<String, dynamic>>()
        .map(Post.fromJson)
        .take(15) // the real endpoint returns 100 — plenty for a demo list
        .toList();

    return ApiResponse(statusCode: response.statusCode, data: posts);
  }

  /// POST /posts. JSONPlaceholder doesn't really save it, but it echoes the
  /// body back with a fake id (101), which is enough to show the round trip.
  Future<ApiResponse<Post>> createPost({
    required String title,
    required String body,
  }) async {
    final response = await _client.post(
      _base,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'userId': 1, 'title': title, 'body': body}),
    );

    if (response.statusCode != 201) {
      throw Exception('POST /posts failed: ${response.statusCode}');
    }

    final post = Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    return ApiResponse(statusCode: response.statusCode, data: post);
  }

  /// GET /posts/{id} — one post, fetched using the id a previous screen
  /// handed this screen. This is the whole point of "passing data between
  /// screens": the id travels, and this screen uses it to ask for its own
  /// data instead of the caller doing that work up front.
  Future<ApiResponse<Post>> fetchPost(int id) async {
    final response = await _client.get(Uri.parse('$_base/$id'));

    if (response.statusCode != 200) {
      throw Exception('GET /posts/$id failed: ${response.statusCode}');
    }

    final post = Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    return ApiResponse(statusCode: response.statusCode, data: post);
  }

  /// GET /posts/{id}/comments — a nested resource, addressed by the same id.
  Future<ApiResponse<List<Comment>>> fetchComments(int postId) async {
    final response = await _client.get(Uri.parse('$_base/$postId/comments'));

    if (response.statusCode != 200) {
      throw Exception('GET /posts/$postId/comments failed: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    final comments = body.cast<Map<String, dynamic>>().map(Comment.fromJson).toList();
    return ApiResponse(statusCode: response.statusCode, data: comments);
  }

  /// PATCH /posts/{id} — the API call the "edit title, then come back" flow
  /// makes once the edit screen has popped its result back to the caller.
  Future<ApiResponse<Post>> updatePost(int id, {required String title}) async {
    final response = await _client.patch(
      Uri.parse('$_base/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'title': title}),
    );

    if (response.statusCode != 200) {
      throw Exception('PATCH /posts/$id failed: ${response.statusCode}');
    }

    final post = Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    return ApiResponse(statusCode: response.statusCode, data: post);
  }
}
