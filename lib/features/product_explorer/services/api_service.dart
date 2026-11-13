import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

/// Talks to fakestoreapi.com — the only file in this app that knows the
/// URLs or JSON shape of the backend.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _base = 'https://fakestoreapi.com';

  Future<List<Product>> fetchAllProducts() async {
    final response = await _client.get(Uri.parse('$_base/products'));
    if (response.statusCode != 200) {
      throw Exception('GET /products failed with status ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>().map(Product.fromJson).toList();
  }

  Future<List<String>> fetchCategories() async {
    final response = await _client.get(Uri.parse('$_base/products/categories'));
    if (response.statusCode != 200) {
      throw Exception('GET /products/categories failed with status ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded.cast<String>();
  }
}
