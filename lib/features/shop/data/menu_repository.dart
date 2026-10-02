import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/dish.dart';

class MenuRepository {
  Future<List<Dish>> load() async {
    final text = await rootBundle.loadString('assets/menu.json');
    final list = jsonDecode(text) as List<dynamic>;
    return list.cast<Map<String, dynamic>>().map(Dish.fromJson).toList();
  }
}
