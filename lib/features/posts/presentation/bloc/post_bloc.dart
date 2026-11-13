
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
