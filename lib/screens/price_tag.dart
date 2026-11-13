import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../models/product.dart';

/// Current price in bold, the invented "original" price struck through
/// beside it, and a "-20%" badge — shared by the row, detail, and
/// favorites screens so the "deal" always reads the same way.
class PriceTag extends StatelessWidget {
  const PriceTag({super.key, required this.product, this.large = false});

  final Product product;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 2,
      children: [
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: large ? 26 : 14,
            fontWeight: FontWeight.w800,
            color: kAccentDeep,
          ),
        ),
        Text(
          '\$${product.originalPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: large ? 15 : 12,
            color: kMuted,
            decoration: TextDecoration.lineThrough,
            decorationColor: kMuted,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '-${Product.discountPercent}%',
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// A small flame ribbon for top-rated products, meant to sit in the
/// corner of a thumbnail.
class HotBadge extends StatelessWidget {
  const HotBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kAccent, kAccentDeep]),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: kAccent.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, size: 11, color: Colors.white),
          SizedBox(width: 2),
          Text('HOT', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white)),
        ],
      ),
    );
  }
}
