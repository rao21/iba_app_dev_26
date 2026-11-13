import 'package:equatable/equatable.dart';

import '../models/product.dart';

/// The chip shown first in the category row, meaning "don't filter".
const kAllCategories = 'All';

/// One state shape with flags, rather than a sealed hierarchy — this
/// screen needs several pieces of state at once (is it loading, is there
/// an error, what's the full catalogue, what's currently visible), not a
/// single "mode" the UI switches between.
class ProductState extends Equatable {
  const ProductState({
    required this.isLoading,
    required this.errorMessage,
    required this.allProducts,
    required this.visibleProducts,
    required this.categories,
    required this.selectedCategory,
    required this.searchQuery,
  });

  factory ProductState.initial() => const ProductState(
        isLoading: true,
        errorMessage: null,
        allProducts: [],
        visibleProducts: [],
        categories: [kAllCategories],
        selectedCategory: kAllCategories,
        searchQuery: '',
      );

  final bool isLoading;
  final String? errorMessage;
  final List<Product> allProducts;
  final List<Product> visibleProducts;
  final List<String> categories;
  final String selectedCategory;
  final String searchQuery;

  ProductState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Product>? allProducts,
    List<Product>? visibleProducts,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      // errorMessage has no fallback to `this.errorMessage` — every call
      // site passes it explicitly (null to clear it, a message to set it)
      // so a stale error can't linger after a successful reload.
      errorMessage: errorMessage,
      allProducts: allProducts ?? this.allProducts,
      visibleProducts: visibleProducts ?? this.visibleProducts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        allProducts,
        visibleProducts,
        categories,
        selectedCategory,
        searchQuery,
      ];
}
