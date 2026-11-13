import 'package:equatable/equatable.dart';

/// One product from fakestoreapi.com.
class Product extends Equatable {
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

  @override
  List<Object?> get props => [id, title, description, price, category, image, rating, ratingCount];
}
