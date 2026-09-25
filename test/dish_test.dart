import 'package:flutter_test/flutter_test.dart';

import 'package:iba_app_dev_26/features/shop/data/menu_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('menu.json loads into Dish objects', () async {
    final dishes = await MenuRepository().load();

    expect(dishes.length, 6);
    expect(dishes.first.name, 'Biryani');
    expect(dishes.first.price, 350);
  });
}
