import 'dart:io';

import '../../domain/entities/post.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_data_source.dart';

/// The bridge between data and domain. This is the only place in the whole
/// feature that imports both a domain type (PostRepository, Failure) and a
/// data type (PostRemoteDataSource, ServerException) — everywhere else,
/// domain and data don't know about each other at all.
class PostRepositoryImpl implements PostRepository {
  const PostRepositoryImpl(this._remoteDataSource);

  final PostRemoteDataSource _remoteDataSource;

  @override
  Future<List<Post>> getPosts() async {
    try {
      // PostModel extends Post, so this returned list already satisfies
      // Future<List<Post>> — no explicit mapping needed.
      return await _remoteDataSource.getPosts();
    } on ServerException catch (e) {
      // Translate the data-layer exception into a domain-level Failure
      // before it crosses into presentation. Presentation code should
      // never need to know what ServerException even is.
      throw ServerFailure(e.message);
    } on SocketException {
      // No DNS, no connection, airplane mode — the request never reached
      // the server at all, so there's no ServerException to catch. Still a
      // Failure as far as presentation is concerned, just a different message.
      throw const ServerFailure('No internet connection. Check your network and try again.');
    }
  }
}
