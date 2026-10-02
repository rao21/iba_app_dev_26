import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:iba_app_dev_26/features/shop/data/menu_repository.dart';
import 'package:iba_app_dev_26/features/shop/models/dish.dart';
import 'package:iba_app_dev_26/features/shop/providers/cart_model.dart';
import 'package:iba_app_dev_26/main.dart';

const _dishes = [
  Dish(id: 1, name: 'Chai', price: 80, emoji: '☕'),
  Dish(id: 2, name: 'Samosa', price: 40, emoji: '🥟'),
];

/// A menu that answers instantly, without reading assets/menu.json.
class _FakeMenu extends MenuRepository {
  @override
  Future<List<Dish>> load() async => _dishes;
}

/// Starts the app and waits for the menu to finish loading.
Future<void> _startApp(WidgetTester tester) async {
  await tester.pumpWidget(ShopApp(repository: _FakeMenu()));
  await tester.pumpAndSettle();
}

Finder _add(int id) => find.byKey(ValueKey('add_$id'));
Finder _plus(int id) => find.byKey(ValueKey('plus_$id'));
Finder _minus(int id) => find.byKey(ValueKey('minus_$id'));

void main() {
  testWidgets('shows a spinner first, then the menu', (tester) async {
    await tester.pumpWidget(ShopApp(repository: _FakeMenu()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Chai'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Chai'), findsOneWidget);
  });

  testWidgets('shows every dish on the menu', (tester) async {
    await _startApp(tester);

    expect(find.text('Chai'), findsOneWidget);
    expect(find.text('Rs 40'), findsOneWidget);
  });

  testWidgets('Add puts the dish in the shared cart', (tester) async {
    await _startApp(tester);

    await tester.tap(_add(1));
    await tester.pump();

    final cart = tester.element(find.byType(Scaffold)).read<CartModel>();
    expect(cart.count, 1);
    expect(cart.total, 80);
  });

  testWidgets('Add turns into a stepper and the badge counts plates', (tester) async {
    await _startApp(tester);
    expect(find.text('View cart'), findsOneWidget); // always there, even when empty
    expect(_plus(1), findsNothing);

    await tester.tap(_add(1));
    await tester.pump();
    expect(_add(1), findsNothing); // the button became a stepper
    expect(_plus(1), findsOneWidget);

    await tester.tap(_plus(1));
    await tester.tap(_add(2));
    await tester.pump();

    expect(find.text('3 items  \u00b7  Rs 200'), findsOneWidget); // 80+80+40, floating button

    await tester.tap(_minus(1));
    await tester.pump();
    expect(find.text('2 items  \u00b7  Rs 120'), findsOneWidget);
  });

  testWidgets('the cart screen shows the same cart and places the order', (tester) async {
    await _startApp(tester);

    await tester.tap(_add(1));
    await tester.pump();
    await tester.tap(_plus(1));
    await tester.tap(_add(2));
    await tester.pump();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Rs 200'), findsOneWidget); // total: 80 + 80 + 40

    await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
    await tester.pump();
    expect(find.text('Rs 120'), findsOneWidget);

    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();

    expect(find.text('Order placed! Rs 120'), findsOneWidget);
    expect(find.text('Menu'), findsOneWidget); // back on the menu
    expect(_add(1), findsOneWidget); // cart was emptied

    await tester.pump(const Duration(seconds: 5)); // flush the SnackBar timer
  });
}
