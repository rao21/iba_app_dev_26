import 'package:flutter_test/flutter_test.dart';

import 'package:iba_app_dev_26/features/shop/data/menu_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('menu.json loads into Dish objects', () async {
    final dishes = await MenuRepository().load();

    expect(dishes.length, 8);
    expect(dishes.first.name, 'Margherita Pizza');
    expect(dishes.first.price, 700);
    // every photo link must be a real https link
    expect(
      dishes.where((d) => d.image != null).every((d) => d.image!.startsWith('https://')),
      isTrue,
    );
  });
}
