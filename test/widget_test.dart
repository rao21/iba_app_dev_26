import 'package:flutter_test/flutter_test.dart';

import 'package:iba_app_dev_26/features/shop/models/dish.dart';
import 'package:iba_app_dev_26/main.dart';

void main() {
  testWidgets('app starts with the menu', (tester) async {
    const dishes = [Dish(id: 1, name: 'Chai', price: 80, emoji: '☕')];
    await tester.pumpWidget(const ShopApp(dishes: dishes));

    expect(find.text('Menu loaded: 1 dishes'), findsOneWidget);
  });
}
