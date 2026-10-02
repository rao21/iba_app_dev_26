import 'package:flutter_test/flutter_test.dart';

import 'package:iba_app_dev_26/features/shop/data/menu_repository.dart';
import 'package:iba_app_dev_26/features/shop/models/dish.dart';
import 'package:iba_app_dev_26/features/shop/providers/menu_provider.dart';

class _Works extends MenuRepository {
  @override
  Future<List<Dish>> load() async =>
      const [Dish(id: 1, name: 'Chai', price: 80, emoji: '☕')];
}

class _Breaks extends MenuRepository {
  @override
  Future<List<Dish>> load() async => throw Exception('no menu');
}

void main() {
  test('starts loading, then has the dishes', () async {
    final menu = MenuProvider(_Works());
    expect(menu.status, MenuStatus.loading);

    var notified = 0;
    menu.addListener(() => notified++);
    await menu.load();

    expect(menu.status, MenuStatus.ready);
    expect(menu.dishes.single.name, 'Chai');
    expect(notified, 1);
  });

  test('a failing repository ends in the error state', () async {
    final menu = MenuProvider(_Breaks());

    await menu.load();

    expect(menu.status, MenuStatus.error);
    expect(menu.dishes, isEmpty);
  });
}
