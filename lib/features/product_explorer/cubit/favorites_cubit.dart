import 'package:flutter_bloc/flutter_bloc.dart';

/// Which product ids are starred — a Cubit because there's really only one
/// thing this state ever does: toggle a membership. No events needed.
class FavoritesCubit extends Cubit<Set<int>> {
  FavoritesCubit() : super(<int>{});

  void toggle(int productId) {
    final next = Set<int>.from(state);
    if (!next.remove(productId)) {
      next.add(productId);
    }
    emit(next);
  }
}
