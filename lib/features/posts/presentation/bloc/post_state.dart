import 'package:equatable/equatable.dart';

import '../../domain/entities/post.dart';

sealed class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

/// Before FetchPosts has ever been added — practically invisible, since
/// PostsPage adds FetchPosts the moment the BLoC is created.
class PostInitial extends PostState {
  const PostInitial();
}

class PostLoading extends PostState {
  const PostLoading();
}

class PostLoaded extends PostState {
  const PostLoaded(this.posts);

  final List<Post> posts;

  @override
  List<Object?> get props => [posts];
}

class PostError extends PostState {
  const PostError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
