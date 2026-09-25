import 'package:flutter/material.dart';

import 'features/shop/data/menu_repository.dart';
import 'features/shop/models/dish.dart';
import 'features/shop/pages/menu_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dishes = await MenuRepository().load();
  runApp(ShopApp(dishes: dishes));
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key, required this.dishes});

  final List<Dish> dishes;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desi Corner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange)),
      home: MenuPage(dishes: dishes),
    );
  }
}
