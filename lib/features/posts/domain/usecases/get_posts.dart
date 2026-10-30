import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// One use case, one job: get the list of posts. A callable class instead
/// of a bare repository method so the presentation layer depends on "the
/// thing that fetches posts" rather than reaching into the repository
/// directly — handy once a feature has more than one use case per entity.
class GetPosts {
  const GetPosts(this._repository);

  final PostRepository _repository;

  Future<List<Post>> call() => _repository.getPosts();
}
