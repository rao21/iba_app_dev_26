import '../models/product.dart';

/// A hard-coded catalogue. Provider is about *state*, not networking, so the
/// data stays local and the lecture stays on one idea.
const products = <Product>[
  Product(id: 1, name: 'Chai', price: 80, emoji: '☕'),
  Product(id: 2, name: 'Samosa', price: 40, emoji: '🥟'),
  Product(id: 3, name: 'Biryani', price: 350, emoji: '🍛'),
  Product(id: 4, name: 'Burger', price: 280, emoji: '🍔'),
  Product(id: 5, name: 'Lassi', price: 120, emoji: '🥛'),
  Product(id: 6, name: 'Kheer', price: 150, emoji: '🍮'),
];
