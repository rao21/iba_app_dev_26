/// One product from fakestoreapi.com.
class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.image,
    required this.rating,
    required this.ratingCount,
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;

  /// fakestoreapi has no discount field — this app invents one flat 20%
  /// "deal" consistently from [price], purely for the "Deals" branding.
  double get originalPrice => price / 0.8;

  static const discountPercent = 20;

  /// A top-rated item gets a "HOT" badge — ties the flame branding on
  /// Splash to something real in the data, not just decoration.
  bool get isHot => rating >= 4.5;

  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingJson = json['rating'] as Map<String, dynamic>? ?? const {};
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      image: json['image'] as String,
      rating: (ratingJson['rate'] as num?)?.toDouble() ?? 0,
      ratingCount: (ratingJson['count'] as num?)?.toInt() ?? 0,
    );
  }
}
