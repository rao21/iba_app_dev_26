import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dish.dart';
import '../providers/cart_model.dart';

/// The menu screen. Add sends the dish to the shared CartModel.
class MenuPage extends StatelessWidget {
  const MenuPage({super.key, required this.dishes});

  final List<Dish> dishes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Desi Corner')),
      body: ListView.builder(
        itemCount: dishes.length,
        itemBuilder: (context, index) {
          final dish = dishes[index];
          return ListTile(
            leading: Text(dish.emoji, style: const TextStyle(fontSize: 28)),
            title: Text(dish.name),
            subtitle: Text('Rs ${dish.price}'),
            trailing: FilledButton(
              // read = "do something once". Use it inside button presses.
              onPressed: () => context.read<CartModel>().add(dish),
              child: const Text('Add'),
            ),
          );
        },
      ),
    );
  }
}
