import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_colors.dart';
import '../models/product.dart';
import '../providers/product_providers.dart';
import 'favorites_screen.dart';
import 'product_detail_screen.dart';
import 'product_row.dart';

const _kAllCategories = 'All';

/// A top TabBar — one tab per category plus "All" — and a ListView of
/// rows per tab, each sorted by rating descending. Deliberately a
/// different layout from the sibling grid+chips app, same data.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) => _HomeScaffold(tabs: [_kAllCategories, ...categories]),
      loading: () => const Scaffold(
        backgroundColor: kBackground,
        body: Center(child: CircularProgressIndicator(color: kAccent)),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: kBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not load categories.', style: TextStyle(color: kMuted)),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: kAccent),
                  onPressed: () => ref.invalidate(categoriesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeScaffold extends ConsumerWidget {
  const _HomeScaffold({required this.tabs});

  final List<String> tabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: kBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kAccent, kAccentDeep],
              ),
            ),
          ),
          title: Row(
            children: const [
              Icon(Icons.local_fire_department_rounded, size: 22),
              SizedBox(width: 6),
              Text('Fakestore Deals', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Favorites',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              ),
              icon: const Icon(Icons.favorite_rounded),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                labelColor: kAccentDeep,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.85),
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: [for (final tab in tabs) Tab(text: _titleCase(tab))],
              ),
            ),
          ),
        ),
        body: productsAsync.when(
          data: (products) => TabBarView(
            children: [
              for (final tab in tabs) _ProductListTab(category: tab, allProducts: products),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: kAccent)),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: kAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.wifi_off_rounded, size: 36, color: kAccent),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Could not load products. Check your connection and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kMuted),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: kAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    ),
                    onPressed: () => ref.invalidate(productsProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value
        .split(' ')
        .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}

class _ProductListTab extends StatelessWidget {
  const _ProductListTab({required this.category, required this.allProducts});

  final String category;
  final List<Product> allProducts;

  @override
  Widget build(BuildContext context) {
    final products = allProducts.where((p) => category == _kAllCategories || p.category == category).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));

    if (products.isEmpty) {
      return const Center(
        child: Text('No products in this category.', style: TextStyle(color: kMuted)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductRow(
          product: product,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
          ),
        );
      },
    );
  }
}
