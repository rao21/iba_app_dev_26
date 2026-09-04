import 'package:flutter/material.dart';

import 'demos/advanced_page.dart';
import 'demos/basics_page.dart';
import 'demos/input_page.dart';
import 'demos/layout_page.dart';
import 'demos/list_page.dart';
import 'demos/more_page.dart';
import 'demos/navigation_page.dart';
import 'demos/state_page.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(const WidgetGalleryApp());
}

/// Lecture 01 companion app: every widget we cover, running, with the code
/// that produced it one tap away.
class WidgetGalleryApp extends StatefulWidget {
  const WidgetGalleryApp({super.key});

  @override
  State<WidgetGalleryApp> createState() => _WidgetGalleryAppState();
}

class _WidgetGalleryAppState extends State<WidgetGalleryApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Gallery',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      home: GalleryHome(onToggleTheme: _toggleTheme),
    );
  }
}

/// One section of the gallery.
class GallerySection {
  const GallerySection({
    required this.label,
    required this.icon,
    required this.page,
  });

  final String label;
  final IconData icon;
  final Widget page;
}

const _sections = <GallerySection>[
  GallerySection(
    label: 'Basics',
    icon: Icons.text_fields,
    page: BasicsPage(),
  ),
  GallerySection(
    label: 'Layout',
    icon: Icons.dashboard_outlined,
    page: LayoutPage(),
  ),
  GallerySection(
    label: 'Input',
    icon: Icons.touch_app_outlined,
    page: InputPage(),
  ),
  GallerySection(
    label: 'Lists',
    icon: Icons.list_alt,
    page: ListPage(),
  ),
  GallerySection(
    label: 'State',
    icon: Icons.sync,
    page: StatePage(),
  ),
  GallerySection(
    label: 'Navigation',
    icon: Icons.menu_open,
    page: NavigationPage(),
  ),
  GallerySection(
    label: 'Advanced',
    icon: Icons.auto_awesome,
    page: AdvancedPage(),
  ),
  GallerySection(
    label: 'More',
    icon: Icons.widgets_outlined,
    page: MorePage(),
  ),
];

/// Holds the selected section. A NavigationRail on wide screens, a
/// NavigationBar on phones — same content either way.
class GalleryHome extends StatefulWidget {
  const GalleryHome({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<GalleryHome> createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<GalleryHome> {
  /// Bottom bar: 0 = Home (the gallery), 1 = Profile.
  int _tab = 0;

  /// Which gallery section Home is showing. Chosen from the drawer, or from
  /// the rail on a wide screen.
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final onHome = _tab == 0;
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    // IndexedStack keeps every page alive, so a switch away and back does not
    // reset the counters and text fields the class is playing with.
    final gallery = IndexedStack(
      index: _index,
      children: [for (final s in _sections) s.page],
    );

    final home = isWide
        ? Row(
            children: [
              // Seven sections can be taller than a short window — let the
              // rail scroll instead of overflowing.
              SingleChildScrollView(
                child: IntrinsicHeight(
                  child: NavigationRail(
                    selectedIndex: _index,
                    groupAlignment: -1,
                    labelType: NavigationRailLabelType.all,
                    onDestinationSelected: (i) => setState(() => _index = i),
                    destinations: [
                      for (final s in _sections)
                        NavigationRailDestination(
                          icon: Icon(s.icon),
                          label: Text(s.label),
                        ),
                    ],
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: gallery),
            ],
          )
        : gallery;

    return Scaffold(
      // The gallery's own Drawer — the widget from the Navigation section,
      // doing its real job: picking which section Home shows.
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Widget Gallery',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Text('App Development 2026 · Lecture 01'),
                  ],
                ),
              ),
            ),
            for (var i = 0; i < _sections.length; i++)
              ListTile(
                leading: Icon(_sections[i].icon),
                title: Text(_sections[i].label),
                selected: onHome && i == _index,
                onTap: () {
                  setState(() {
                    _index = i;
                    _tab = 0; // sections live on Home
                  });
                  Navigator.pop(context); // close the drawer
                },
              ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          onHome ? 'Widget Gallery · ${_sections[_index].label}' : 'Profile',
        ),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: const Icon(Icons.brightness_6_outlined),
            tooltip: 'Toggle light and dark',
          ),
        ],
      ),
      body: onHome ? home : const ProfilePage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
