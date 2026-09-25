import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_model.dart';

/// A second screen showing the SAME cart. Nothing is passed through the
/// constructor — it just asks Provider.
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your order')),
      // Consumer = watch, but only this part redraws.
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }
          return ListView(
            children: [
              for (final entry in cart.items.entries)
                ListTile(
                  leading: Text(
                    entry.key.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(entry.key.name),
                  subtitle: Text('Rs ${entry.key.price} each'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => cart.remove(entry.key),
                      ),
                      Text('${entry.value}'),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => cart.add(entry.key),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<CartModel>(
        builder: (context, cart, child) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Total: Rs ${cart.total}',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.end,
          ),
        ),
      ),
    );
  }
}
