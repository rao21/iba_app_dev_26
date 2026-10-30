import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

/// Asks the BLoC to (re)load the post list — used both on first load and
/// whenever the user retries (error button, pull-to-refresh).
class FetchPosts extends PostEvent {
  const FetchPosts();
}
