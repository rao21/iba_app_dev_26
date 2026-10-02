import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dish.dart';
import '../providers/cart_model.dart';
import '../providers/menu_provider.dart';
import '../widgets/cart_fab.dart';
import '../widgets/dish_card.dart';
import 'cart_page.dart';

/// The menu screen. It asks MenuProvider to load the menu once, in initState,
/// then shows whatever state the model is in: spinner, error, or the grid.
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  void initState() {
    super.initState();
    // read = "do something once". Runs once, when the screen is created.
    context.read<MenuProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      // Consumer redraws this part whenever MenuProvider changes.
      body: Consumer<MenuProvider>(
        builder: (context, menu, child) {
          switch (menu.status) {
            case MenuStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case MenuStatus.error:
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load the menu'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: menu.retry,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              );
            case MenuStatus.ready:
            return  _MenuGrid(dishes: menu.dishes);
          }
        },
      ),
      floatingActionButton: const CartFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({required this.dishes});

  final List<Dish> dishes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: dishes.length,
            itemBuilder: (context, index) => DishCard(dish: dishes[index]),
          ),
        ),
      ],
    );
  }
}

/// The cart icon with a number on it. It uses context.watch, so it redraws
/// by itself every time the cart changes.
class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    // watch = "redraw me whenever this changes". Use it inside build().
    final count = context.watch<CartModel>().count;

    return IconButton(
      tooltip: 'Open cart',
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartPage()),
      ),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }
}
