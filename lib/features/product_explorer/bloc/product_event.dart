import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches every product and category once. Category filtering and search
/// afterwards happen entirely in memory — no extra API calls.
class LoadProducts extends ProductEvent {
  const LoadProducts();
}

class FilterByCategory extends ProductEvent {
  const FilterByCategory(this.category);

  final String category;

  @override
  List<Object?> get props => [category];
}

class SearchProducts extends ProductEvent {
  const SearchProducts(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
