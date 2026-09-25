import 'package:flutter_test/flutter_test.dart';

import 'package:iba_app_dev_26/features/shop/data/menu_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('menu.json loads into Dish objects', () async {
    final dishes = await MenuRepository().load();

    expect(dishes.length, 8);
    expect(dishes.first.name, 'Biryani');
    expect(dishes.first.price, 350);
    expect(dishes.first.image, isNull); // not every dish has a photo
    expect(dishes.last.image, startsWith('https://'));
  });
}
