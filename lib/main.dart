import 'package:flutter/material.dart';

import 'features/shop/data/menu_repository.dart';
import 'features/shop/models/dish.dart';

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
      home: Scaffold(
        appBar: AppBar(title: const Text('Desi Corner')),
        body: Center(child: Text('Menu loaded: ${dishes.length} dishes')),
      ),
    );
  }
}
