import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post_model.dart';

/// Thrown when the backend itself is the problem — a non-200 status, or a
/// response that doesn't parse. Stays inside the data layer: callers above
/// this never catch a ServerException directly.
class ServerException implements Exception {
  const ServerException(this.message);

  final String message;
}

/// The one place that knows this app currently gets its posts over HTTP
/// from JSONPlaceholder. Swap this file for a different implementation
/// (GraphQL, a local cache, a different REST API) and nothing above it —
/// not the repository's callers, not the BLoC, not a single widget — has
/// to change, because they all depend on [PostRemoteDataSource]'s
/// signature, not on how it's implemented.
abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts();
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  PostRemoteDataSourceImpl({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final _postsUrl = Uri.parse('https://jsonplaceholder.typicode.com/posts');

  @override
  Future<List<PostModel>> getPosts() async {
    final response = await _client.get(_postsUrl);

    if (response.statusCode != 200) {
      throw ServerException('GET /posts failed with status ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(PostModel.fromJson)
        .toList();
  }
}
