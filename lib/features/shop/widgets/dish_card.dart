import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dish.dart';
import '../providers/cart_model.dart';
import 'dish_image.dart';

/// One dish on the menu: photo, name, price, and either an Add button or a
/// - 2 + stepper, depending on whether it is already in the cart.
class DishCard extends StatelessWidget {
  const DishCard({super.key, required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // watch: this card redraws when the cart changes, so the button can
    // turn into a stepper by itself.
    final quantity = context.watch<CartModel>().quantityOf(dish);
    final cart = context.read<CartModel>();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: DishImage(dish: dish)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Rs ${dish.price}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (quantity == 0)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      key: ValueKey('add_${dish.id}'),
                      onPressed: () => cart.add(dish),
                      child: const Text('Add'),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filledTonal(
                        key: ValueKey('minus_${dish.id}'),
                        onPressed: () => cart.remove(dish),
                        icon: const Icon(Icons.remove),
                      ),
                      Text('$quantity', style: theme.textTheme.titleMedium),
                      IconButton.filled(
                        key: ValueKey('plus_${dish.id}'),
                        onPressed: () => cart.add(dish),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
