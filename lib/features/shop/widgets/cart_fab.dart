import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/cart_page.dart';
import '../providers/cart_model.dart';

/// The floating cart button. It is always on screen: "View cart" when the
/// cart is empty, "2 items · Rs 200" once something is in it.
class CartFab extends StatelessWidget {
  const CartFab({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer redraws just this button when the cart changes.
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        return FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartPage()),
          ),
          icon: const Icon(Icons.shopping_cart),
          label: Text(
            cart.count == 0
                ? 'View cart'
                : '${cart.count} items  \u00b7  Rs ${cart.total}',
          ),
        );
      },
    );
  }
}
