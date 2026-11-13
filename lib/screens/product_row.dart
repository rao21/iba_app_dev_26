import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_colors.dart';
import '../models/product.dart';
import '../providers/favorites_provider.dart';
import 'price_tag.dart';

/// One product as a rounded row card: thumbnail (with a HOT badge for
/// top-rated items), title, price tag, star rating, and a heart toggle.
class ProductRow extends ConsumerWidget {
  const ProductRow({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider.select((ids) => ids.contains(product.id)));

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kInk.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 76,
                        height: 76,
                        color: kBackground,
                        padding: const EdgeInsets.all(10),
                        child: Image.network(
                          product.image,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stack) =>
                              const Icon(Icons.image_not_supported_outlined, color: kMuted, size: 20),
                        ),
                      ),
                    ),
                    if (product.isHot)
                      const Positioned(top: 4, left: 4, child: HotBadge()),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kInk),
                      ),
                      const SizedBox(height: 6),
                      PriceTag(product: product),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: kStar),
                          const SizedBox(width: 2),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12, color: kMuted, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            ' (${product.ratingCount})',
                            style: const TextStyle(fontSize: 11.5, color: kMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _HeartButton(
                  isFavorite: isFavorite,
                  onTap: () => ref.read(favoritesProvider.notifier).toggle(product.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeartButton extends StatelessWidget {
  const _HeartButton({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isFavorite ? kHeart.withValues(alpha: 0.1) : kBackground,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 18,
            color: isFavorite ? kHeart : kMuted,
          ),
        ),
      ),
    );
  }
}
