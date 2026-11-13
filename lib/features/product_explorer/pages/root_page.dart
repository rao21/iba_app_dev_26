import 'package:flutter/material.dart';

import '../widgets/product_card.dart';
import 'favorites_page.dart';
import 'home_page.dart';

/// Holds the bottom nav bar and switches between Home and Favorites. Both
/// tabs stay alive underneath (IndexedStack), so scroll position and the
/// search field keep their state when the user switches tabs and back.
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: IndexedStack(
        index: _index,
        children: const [HomePage(), FavoritesPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        backgroundColor: Colors.white,
        indicatorColor: kAccent.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded, color: kAccent),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded, color: kAccent),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
