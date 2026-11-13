import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_colors.dart';
import '../models/product.dart';
import '../providers/favorites_provider.dart';
import '../providers/product_providers.dart';
import 'price_tag.dart';
import 'product_detail_screen.dart';

/// Favorited products as a horizontal scrolling row of cards — not a
/// vertical grid, on purpose, to look distinct from Home's rows too.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kAccent,
        foregroundColor: Colors.white,
        title: const Text('Favorites', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: productsAsync.when(
        data: (products) {
          final favorites = products.where((p) => favoriteIds.contains(p.id)).toList();

          if (favorites.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border_rounded, size: 48, color: kMuted),
                    SizedBox(height: 12),
                    Text('No favorites yet', style: TextStyle(fontWeight: FontWeight.w700, color: kInk)),
                    SizedBox(height: 4),
                    Text(
                      'Tap the heart on any product to save it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kMuted),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(20),
            itemCount: favorites.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) => _FavoriteCard(product: favorites[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: kAccent)),
        error: (error, stack) => const Center(
          child: Text('Could not load favorites.', style: TextStyle(color: kMuted)),
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 120,
                      width: double.infinity,
                      color: kBackground,
                      padding: const EdgeInsets.all(16),
                      child: Image.network(
                        product.image,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) =>
                            const Center(child: Icon(Icons.image_not_supported_outlined, color: kMuted)),
                      ),
                    ),
                    if (product.isHot) const Positioned(top: 8, left: 8, child: HotBadge()),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kInk),
                      ),
                      const SizedBox(height: 6),
                      PriceTag(product: product),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
