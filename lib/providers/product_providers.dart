import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

/// Loaded once, up front — Splash waits on this, and Home reads it as
/// already-settled data. No category or search filtering happens through
/// the network; it's all done in memory over this one list.
final productsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(apiServiceProvider).fetchProducts();
});

/// The category tabs on Home. A separate call to GET /products/categories
/// rather than deriving categories from [productsProvider], since the API
/// exposes it directly.
final categoriesProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(apiServiceProvider).fetchCategories();
});
