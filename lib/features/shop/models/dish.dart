/// One dish on the menu. It never changes, so every field is final.
class Dish {
  const Dish({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
  });

  final int id;
  final String name;
  final int price;
  final String emoji;

  // Turns one JSON object from menu.json into a Dish.
  factory Dish.fromJson(Map<String, dynamic> json) => Dish(
        id: json['id'] as int,
        name: json['name'] as String,
        price: json['price'] as int,
        emoji: json['emoji'] as String,
      );
}
