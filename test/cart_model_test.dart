import 'package:flutter_test/flutter_test.dart';

import 'package:iba_app_dev_26/features/shop/models/dish.dart';
import 'package:iba_app_dev_26/features/shop/providers/cart_model.dart';

void main() {
  const chai = Dish(id: 1, name: 'Chai', price: 80, emoji: '☕');
  const samosa = Dish(id: 2, name: 'Samosa', price: 40, emoji: '🥟');

  test('adding counts plates and totals the bill', () {
    final cart = CartModel();

    cart.add(chai);
    cart.add(chai);
    cart.add(samosa);

    expect(cart.count, 3);
    expect(cart.total, 200); // 80 + 80 + 40
  });

  test('remove lowers the quantity and drops a dish at zero', () {
    final cart = CartModel()..add(chai)..add(chai);

    cart.remove(chai);
    expect(cart.count, 1);

    cart.remove(chai);
    expect(cart.items.containsKey(chai), false);
  });

  test('every change notifies listeners', () {
    final cart = CartModel();
    var notified = 0;
    cart.addListener(() => notified++);

    cart.add(chai);
    cart.remove(chai);

    expect(notified, 2);
  });
}
