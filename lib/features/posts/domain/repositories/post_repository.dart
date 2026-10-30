import '../entities/post.dart';

/// What the domain layer needs from "wherever posts come from" — nothing
/// more. The presentation layer depends on this, never on PostRepositoryImpl
/// or anything in data/, so the actual source (REST API, GraphQL, cache,
/// whatever) can change without touching a single BLoC or widget.
abstract class PostRepository {
  Future<List<Post>> getPosts();
}
