// Why the domain layer has never heard of http or json:
//
// GetPosts (domain/usecases/get_posts.dart) and PostRepository
// (domain/repositories/post_repository.dart) only talk in terms of Post, a
// plain Dart class. Neither of them imports package:http or dart:convert,
// and neither does this BLoC — it calls `_getPosts()` and gets back a
// List<Post> or a Failure, full stop.
//
// The actual fetching — the URL, the status-code check, the JSON decoding —
// lives entirely in data/datasources/post_remote_data_source.dart and
// data/repositories/post_repository_impl.dart. If JSONPlaceholder were
// swapped for a GraphQL endpoint, a local database, or a different REST
// API tomorrow, the fix is a new data/ implementation of PostRepository.
// This file, GetPosts, PostEvent, PostState, PostsPage, and PostCard would
// not need a single line changed, because none of them know or care how
// "get the posts" is actually done — they only know it can be asked for.
// That's the whole point of the dependency pointing from data toward
// domain, and never the other way around.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/failure.dart';
import '../../domain/usecases/get_posts.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required GetPosts getPosts})
      : _getPosts = getPosts,
        super(const PostInitial()) {
    on<FetchPosts>(_onFetchPosts);
  }

  final GetPosts _getPosts;

  Future<void> _onFetchPosts(FetchPosts event, Emitter<PostState> emit) async {
    emit(const PostLoading());
    try {
      final posts = await _getPosts();
      emit(PostLoaded(posts));
    } on Failure catch (failure) {
      emit(PostError(failure.message));
    }
  }
}
