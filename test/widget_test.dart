import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:iba_app_dev_26/features/shop/models/dish.dart';
import 'package:iba_app_dev_26/features/shop/providers/cart_model.dart';
import 'package:iba_app_dev_26/main.dart';

const _dishes = [
  Dish(id: 1, name: 'Chai', price: 80, emoji: '☕'),
  Dish(id: 2, name: 'Samosa', price: 40, emoji: '🥟'),
];

void main() {
  testWidgets('shows every dish on the menu', (tester) async {
    await tester.pumpWidget(const ShopApp(dishes: _dishes));

    expect(find.text('Chai'), findsOneWidget);
    expect(find.text('Rs 40'), findsOneWidget);
  });

  testWidgets('Add puts the dish in the shared cart', (tester) async {
    await tester.pumpWidget(const ShopApp(dishes: _dishes));

    await tester.tap(find.text('Add').first);
    await tester.pump();

    final cart = tester.element(find.byType(Scaffold)).read<CartModel>();
    expect(cart.count, 1);
    expect(cart.total, 80);
  });
}
