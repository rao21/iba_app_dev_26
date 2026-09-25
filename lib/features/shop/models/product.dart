/// One item in the shop. Immutable: a product never changes, only how many
/// of it are in the cart does.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
  });

  final int id;
  final String name;
  final int price; // in rupees, whole numbers keep the maths simple
  final String emoji;
}
