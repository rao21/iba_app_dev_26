import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/shop/data/menu_repository.dart';
import 'features/shop/pages/menu_page.dart';
import 'features/shop/providers/cart_model.dart';
import 'features/shop/providers/menu_provider.dart';

void main() {
  runApp(const ShopApp());
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key, this.repository});

  /// Where the menu comes from. A test passes a fake one; the real app
  /// leaves it out and reads assets/menu.json.
  final MenuRepository? repository;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.deepOrange);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartModel()),
        ChangeNotifierProvider(
          create: (context) => MenuProvider(repository ?? MenuRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Food Court',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: scheme,
          // Without this, Material 3 tints the AppBar when the list scrolls
          // under it, and the colour seems to change. Fixed colour, no tint.
          appBarTheme: AppBarTheme(
            backgroundColor: scheme.primaryContainer,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: scheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
        home: const MenuPage(),
      ),
    );
  }
}
