import 'package:flutter/material.dart';

import '../models/dish.dart';

/// A small square photo of the dish. No photo, or no internet? It falls back
/// to the emoji, so the screen never looks broken.
class DishImage extends StatelessWidget {
  const DishImage({super.key, required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final emoji = Center(
      child: Text(dish.emoji, style: const TextStyle(fontSize: 28)),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 56,
        height: 56,
        child: dish.image == null
            ? emoji
            : Image.network(
                dish.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => emoji,
              ),
      ),
    );
  }
}
