class Dish {
  const Dish({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
    this.image,
  });

  final int id;
  final String name;
  final int price;
  final String emoji;
  final String? image; 

  factory Dish.fromJson(Map<String, dynamic> json) => Dish(
        id: json['id'] as int,
        name: json['name'] as String,
        price: json['price'] as int,
        emoji: json['emoji'] as String,
        image: json['image'] as String?,
      );
}
