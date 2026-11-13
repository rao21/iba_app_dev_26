import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc(this._api) : super(ProductState.initial()) {
    on<LoadProducts>(_onLoadProducts);
    on<FilterByCategory>(_onFilterByCategory);
    on<SearchProducts>(_onSearchProducts);
  }

  final ApiService _api;

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final products = await _api.fetchAllProducts();
      final categories = await _api.fetchCategories();
      emit(state.copyWith(
        isLoading: false,
        errorMessage: null,
        allProducts: products,
        visibleProducts: _filtered(products, state.selectedCategory, state.searchQuery),
        categories: [kAllCategories, ...categories],
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load products. Check your connection and try again.',
      ));
    }
  }

  void _onFilterByCategory(FilterByCategory event, Emitter<ProductState> emit) {
    emit(state.copyWith(
      errorMessage: state.errorMessage,
      selectedCategory: event.category,
      visibleProducts: _filtered(state.allProducts, event.category, state.searchQuery),
    ));
  }

  void _onSearchProducts(SearchProducts event, Emitter<ProductState> emit) {
    emit(state.copyWith(
      errorMessage: state.errorMessage,
      searchQuery: event.query,
      visibleProducts: _filtered(state.allProducts, state.selectedCategory, event.query),
    ));
  }

  // Category and search apply together — searching "shirt" while the
  // Men's category chip is selected only searches within that category.
  List<Product> _filtered(List<Product> products, String category, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    return products.where((product) {
      final matchesCategory = category == kAllCategories || product.category == category;
      final matchesQuery =
          normalizedQuery.isEmpty || product.title.toLowerCase().contains(normalizedQuery);
      return matchesCategory && matchesQuery;
    }).toList();
  }
}
