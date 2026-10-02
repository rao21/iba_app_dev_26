import 'package:flutter/material.dart';

import '../models/dish.dart';

/// The dish photo. No photo, or no internet? It falls back to the emoji on a
/// soft background, so the screen never looks broken.
///
/// Give it a [size] for a small square (cart rows), or leave [size] out and
/// it fills whatever space its parent gives it (menu cards).
class DishImage extends StatelessWidget {
  const DishImage({super.key, required this.dish, this.size});

  final Dish dish;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final emoji = ColoredBox(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Center(
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(dish.emoji, style: const TextStyle(fontSize: 56)),
          ),
        ),
      ),
    );

    final picture = dish.image == null
        ? emoji
        : Image.network(
            dish.image!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => emoji,
          );

    if (size == null) return picture;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(width: size, height: size, child: picture),
    );
  }
}
