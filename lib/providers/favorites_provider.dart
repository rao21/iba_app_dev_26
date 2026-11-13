import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which product ids are favorited. A plain Notifier, since the only thing
/// this state ever does is toggle membership.
class FavoritesNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => <int>{};

  void toggle(int productId) {
    final next = Set<int>.from(state);
    if (!next.remove(productId)) {
      next.add(productId);
    }
    state = next;
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<int>>(FavoritesNotifier.new);
