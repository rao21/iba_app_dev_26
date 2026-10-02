import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_model.dart';
import '../widgets/dish_image.dart';

/// A second screen showing the SAME cart. Nothing is passed through the
/// constructor — it just asks Provider.
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Your order')),
      // Consumer = watch, but only this part redraws.
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  const Text('Your cart is empty'),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final entry in cart.items.entries)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        DishImage(dish: entry.key, size: 64),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.key.name, style: theme.textTheme.titleMedium),
                              Text('Rs ${entry.key.price} each'),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => cart.remove(entry.key),
                        ),
                        Text('${entry.value}', style: theme.textTheme.titleMedium),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => cart.add(entry.key),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<CartModel>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) return const SizedBox.shrink();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: theme.textTheme.titleMedium),
                      Text('Rs ${cart.total}', style: theme.textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final messenger = ScaffoldMessenger.of(context);
                        final bill = cart.total;
                        cart.clear();
                        Navigator.pop(context);
                        messenger.showSnackBar(
                          SnackBar(content: Text('Order placed! Rs $bill')),
                        );
                      },
                      child: const Text('Place order'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
