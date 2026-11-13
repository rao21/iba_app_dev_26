import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:iba_app_dev_26/main.dart';
import 'package:iba_app_dev_26/models/product.dart';
import 'package:iba_app_dev_26/providers/product_providers.dart';
import 'package:iba_app_dev_26/services/api_service.dart';

/// A fake backend so this test never touches the real network — two
/// categories, with ratings deliberately out of insertion order so a
/// passing sort assertion actually means something.
class _FakeApiService implements ApiService {
  static const _products = [
    Product(
      id: 1,
      title: 'Budget Headphones',
      description: 'Decent sound for the price.',
      price: 19.99,
      category: 'electronics',
      image: 'https://example.com/headphones.png',
      rating: 3.2,
      ratingCount: 40,
    ),
    Product(
      id: 2,
      title: 'Flagship Laptop',
      description: 'Fast, light, expensive.',
      price: 1299.00,
      category: 'electronics',
      image: 'https://example.com/laptop.png',
      rating: 4.9,
      ratingCount: 210,
    ),
    Product(
      id: 3,
      title: 'Cotton T-Shirt',
      description: 'Soft and breathable.',
      price: 14.50,
      category: 'clothing',
      image: 'https://example.com/tshirt.png',
      rating: 4.1,
      ratingCount: 88,
    ),
  ];

  @override
  Future<List<Product>> fetchProducts() async => _products;

  @override
  Future<List<String>> fetchCategories() async => ['electronics', 'clothing'];
}

void main() {
  testWidgets(
    'splash navigates to Home; tab switch, detail nav, and favorite toggle all work',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiServiceProvider.overrideWithValue(_FakeApiService())],
          child: const MyApp(),
        ),
      );

      // Splash is up first.
      expect(find.text('Fakestore Deals'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // The BlocListener-equivalent (ref.listen) fires once the fake
      // fetch settles, and Splash pushReplaces to Home.
      await tester.pumpAndSettle();
      expect(find.byType(TabBar), findsOneWidget);

      // "All" tab: both electronics products plus the clothing one, with
      // the highest-rated item (Flagship Laptop, 4.9) listed first.
      final allTab = tester.getRect(find.widgetWithText(Tab, 'All'));
      expect(allTab, isNotNull);
      expect(find.text('Flagship Laptop'), findsOneWidget);
      expect(find.text('Budget Headphones'), findsOneWidget);
      expect(find.text('Cotton T-Shirt'), findsOneWidget);

      final titles = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList();
      final laptopIndex = titles.indexOf('Flagship Laptop');
      final headphonesIndex = titles.indexOf('Budget Headphones');
      expect(laptopIndex, lessThan(headphonesIndex),
          reason: 'higher-rated product should render before a lower-rated one');

      // --- Tab switching: Clothing tab should hide the electronics items.
      await tester.tap(find.text('Clothing'));
      await tester.pumpAndSettle();
      expect(find.text('Cotton T-Shirt'), findsOneWidget);
      expect(find.text('Flagship Laptop'), findsNothing);
      expect(find.text('Budget Headphones'), findsNothing);

      // --- Detail navigation: tapping the row opens its detail screen.
      await tester.tap(find.text('Cotton T-Shirt'));
      await tester.pumpAndSettle();
      expect(find.text('Soft and breathable.'), findsOneWidget);
      expect(find.text('\$14.50'), findsOneWidget);

      // --- Favorite toggle, from the detail screen.
      await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
      await tester.pump();
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

      // Back to Home, then into Favorites via the AppBar heart icon.
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Favorites'));
      await tester.pumpAndSettle();

      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Cotton T-Shirt'), findsOneWidget);
      expect(find.text('Flagship Laptop'), findsNothing); // never favorited
      expect(find.byType(ListView), findsOneWidget);
      final favoritesListView = tester.widget<ListView>(find.byType(ListView));
      expect(favoritesListView.scrollDirection, Axis.horizontal);
    },
  );
}
