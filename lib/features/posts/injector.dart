import 'data/datasources/post_remote_data_source.dart';
import 'data/repositories/post_repository_impl.dart';
import 'domain/usecases/get_posts.dart';

/// Manual dependency injection for the posts feature: wires
/// data source -> repository -> use case, in that order, so PostsPage only
/// ever has to ask for a [GetPosts].
GetPosts buildGetPosts() {
  final remoteDataSource = PostRemoteDataSourceImpl();
  final repository = PostRepositoryImpl(remoteDataSource);
  return GetPosts(repository);
}
