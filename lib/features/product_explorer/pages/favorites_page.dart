import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/product_bloc.dart';
import '../bloc/product_state.dart';
import '../cubit/favorites_cubit.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

/// Reads ProductBloc for the full catalogue and FavoritesCubit for which
/// ids are starred, and shows the intersection of the two.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              'Favorites',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kInk),
            ),
          ),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, productState) {
                return BlocBuilder<FavoritesCubit, Set<int>>(
                  builder: (context, favoriteIds) {
                    final favorites = productState.allProducts
                        .where((product) => favoriteIds.contains(product.id))
                        .toList();

                    if (favorites.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.favorite_border_rounded, size: 48, color: kMuted),
                              SizedBox(height: 12),
                              Text(
                                'No favorites yet',
                                style: TextStyle(fontWeight: FontWeight.w700, color: kInk),
                              ),
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

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.66,
                      ),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final product = favorites[index];
                        return ProductCard(
                          product: product,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(product: product),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
