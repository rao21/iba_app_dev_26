import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

/// Search bar, category chips, and the product grid. Search and category
/// filtering both dispatch to [ProductBloc], which combines them in memory.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              'Discover',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kInk),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: _SearchField(
              controller: _searchController,
              onChanged: (query) => context.read<ProductBloc>().add(SearchProducts(query)),
            ),
          ),
          const _CategoryChipRow(),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state.isLoading && state.allProducts.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: kAccent));
                }
                if (state.errorMessage != null && state.allProducts.isEmpty) {
                  return _ErrorState(
                    message: state.errorMessage!,
                    onRetry: () => context.read<ProductBloc>().add(const LoadProducts()),
                  );
                }
                if (state.visibleProducts.isEmpty) {
                  return const _EmptyState();
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.66,
                  ),
                  itemCount: state.visibleProducts.length,
                  itemBuilder: (context, index) {
                    final product = state.visibleProducts[index];
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
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search products',
        hintStyle: const TextStyle(color: kMuted),
        prefixIcon: const Icon(Icons.search_rounded, color: kMuted),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CategoryChipRow extends StatelessWidget {
  const _CategoryChipRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: BlocBuilder<ProductBloc, ProductState>(
        buildWhen: (previous, current) =>
            previous.categories != current.categories ||
            previous.selectedCategory != current.selectedCategory,
        builder: (context, state) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: state.categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = state.categories[index];
              final selected = category == state.selectedCategory;
              return GestureDetector(
                onTap: () => context.read<ProductBloc>().add(FilterByCategory(category)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? kAccent : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: selected ? null : Border.all(color: const Color(0xFFE4E3EF)),
                  ),
                  child: Text(
                    _titleCase(category),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : kMuted,
                    ),
                  ),
                ),
              );
            },
          );
        },
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: kMuted),
            SizedBox(height: 12),
            Text('No products match', style: TextStyle(fontWeight: FontWeight.w700, color: kInk)),
            SizedBox(height: 4),
            Text(
              'Try a different search term or category.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.wifi_off_rounded, size: 36, color: kAccent),
            ),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: kMuted)),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: kAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
