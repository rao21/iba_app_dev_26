import 'package:flutter_test/flutter_test.dart';

import 'package:iba_app_dev_26/features/shop/models/dish.dart';
import 'package:iba_app_dev_26/main.dart';

void main() {
  testWidgets('shows every dish on the menu', (tester) async {
    const dishes = [
      Dish(id: 1, name: 'Chai', price: 80, emoji: '☕'),
      Dish(id: 2, name: 'Samosa', price: 40, emoji: '🥟'),
    ];
    await tester.pumpWidget(const ShopApp(dishes: dishes));

    expect(find.text('Chai'), findsOneWidget);
    expect(find.text('Rs 40'), findsOneWidget);
  });
}
