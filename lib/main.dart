import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/shop/data/menu_repository.dart';
import 'features/shop/models/dish.dart';
import 'features/shop/pages/menu_page.dart';
import 'features/shop/providers/cart_model.dart';

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
    // Put the CartModel ABOVE MaterialApp so every screen can reach the
    // same cart. create: runs once, and Provider disposes it for us.
    return ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: MaterialApp(
        title: 'Desi Corner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MenuPage(dishes: dishes),
      ),
    );
  }
}
