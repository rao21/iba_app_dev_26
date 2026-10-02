import 'package:flutter/foundation.dart';

import '../models/dish.dart';

/// The cart. It remembers what was added and shouts "I changed!" every time,
/// so any screen listening can redraw itself.
class CartModel extends ChangeNotifier {
  // dish -> how many of it are in the cart
  final Map<Dish, int> _items = {};

  Map<Dish, int> get items => Map.unmodifiable(_items);

  // Total number of plates, e.g. 2 biryani + 1 chai = 3.
  int get count => _items.values.fold(0, (sum, qty) => sum + qty);

  // Total bill in rupees.
  int get total =>
      _items.entries.fold(0, (sum, e) => sum + e.key.price * e.value);

  // How many of this one dish are in the cart (0 if none).
  int quantityOf(Dish dish) => _items[dish] ?? 0;

  void add(Dish dish) {
    _items[dish] = (_items[dish] ?? 0) + 1;
    notifyListeners(); // <- the whole point of ChangeNotifier
  }

  void remove(Dish dish) {
    final qty = _items[dish];
    if (qty == null) return;
    if (qty <= 1) {
      _items.remove(dish);
    } else {
      _items[dish] = qty - 1;
    }
    notifyListeners();
  }

  // Order placed: empty the cart.
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
