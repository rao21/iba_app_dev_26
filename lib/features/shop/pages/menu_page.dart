import 'package:flutter/material.dart';

import '../models/dish.dart';

/// The menu screen. The Add button does nothing yet — that is the problem
/// Provider is about to solve.
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
              onPressed: () {},
              child: const Text('Add'),
            ),
          );
        },
      ),
    );
  }
}
