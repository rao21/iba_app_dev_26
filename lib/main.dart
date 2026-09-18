import 'package:flutter/material.dart';

import 'features/api_lecture/pages/api_page.dart';
import 'features/api_lecture/services/posts_api.dart';
import 'features/navigation_lecture/pages/post_detail_page.dart';
import 'features/navigation_lecture/pages/routing_lecture_page.dart';
import 'features/profile/pages/profile_page.dart';
import 'features/widgets_lecture/pages/advanced_page.dart';
import 'features/widgets_lecture/pages/basics_page.dart';
import 'features/widgets_lecture/pages/input_page.dart';
import 'features/widgets_lecture/pages/layout_page.dart';
import 'features/widgets_lecture/pages/list_page.dart';
import 'features/widgets_lecture/pages/more_page.dart';
import 'features/widgets_lecture/pages/navigation_page.dart';
import 'features/widgets_lecture/pages/state_page.dart';

void main() {
  runApp(const WidgetGalleryApp());
}

/// Lecture 01 companion app: every widget we cover, running, with the code
/// that produced it one tap away.
class WidgetGalleryApp extends StatefulWidget {
  const WidgetGalleryApp({super.key, PostsApi? api}) : _api = api;

  /// Lets a test hand every API-backed section the same fake client instead
  /// of each one reaching for the real network on its own.
  final PostsApi? _api;

  @override
  State<WidgetGalleryApp> createState() => _WidgetGalleryAppState();
}

class _WidgetGalleryAppState extends State<WidgetGalleryApp> {
  late final PostsApi _api = widget._api ?? PostsApi();
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
      home: GalleryHome(api: _api, onToggleTheme: _toggleTheme),
      // The named-route half of Lecture 03: one place that maps an address
      // to a screen, so Navigator.pushNamed elsewhere never has to know how
      // PostDetailPage is built.
      onGenerateRoute: (settings) {
        if (settings.name == RoutingLecturePage.routeName) {
          final postId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => PostDetailPage(postId: postId, api: _api),
          );
        }
        return null;
      },
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

/// Every section of the gallery. Only the two API-backed lectures need
/// [api] — everyone else is a `const` page with nothing to inject.
List<GallerySection> _buildSections(PostsApi api) => [
      const GallerySection(
        label: 'Basics',
        icon: Icons.text_fields,
        page: BasicsPage(),
      ),
      const GallerySection(
        label: 'Layout',
        icon: Icons.dashboard_outlined,
        page: LayoutPage(),
      ),
      const GallerySection(
        label: 'Input',
        icon: Icons.touch_app_outlined,
        page: InputPage(),
      ),
      const GallerySection(
        label: 'Lists',
        icon: Icons.list_alt,
        page: ListPage(),
      ),
      const GallerySection(
        label: 'State',
        icon: Icons.sync,
        page: StatePage(),
      ),
      const GallerySection(
        label: 'Navigation',
        icon: Icons.menu_open,
        page: NavigationPage(),
      ),
      const GallerySection(
        label: 'Advanced',
        icon: Icons.auto_awesome,
        page: AdvancedPage(),
      ),
      GallerySection(
        label: 'API',
        icon: Icons.cloud_outlined,
        page: ApiPage(api: api),
      ),
      GallerySection(
        label: 'Routing',
        icon: Icons.alt_route,
        page: RoutingLecturePage(api: api),
      ),
      const GallerySection(
        label: 'More',
        icon: Icons.widgets_outlined,
        page: MorePage(),
      ),
    ];

/// Holds the selected section. A NavigationRail on wide screens, a
/// NavigationBar on phones — same content either way.
class GalleryHome extends StatefulWidget {
  const GalleryHome({super.key, required this.api, required this.onToggleTheme});

  final PostsApi api;
  final VoidCallback onToggleTheme;

  @override
  State<GalleryHome> createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<GalleryHome> {
  /// Built once per widget.api so every section's IndexedStack slot keeps
  /// its identity (and its state) across rebuilds.
  late final _sections = _buildSections(widget.api);

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
      // Profile draws its own animated SliverAppBar, so only Home uses the
      // plain top bar.
      appBar: onHome
          ? AppBar(
              title: Text('Widget Gallery · ${_sections[_index].label}'),
              actions: [
                IconButton(
                  onPressed: widget.onToggleTheme,
                  icon: const Icon(Icons.brightness_6_outlined),
                  tooltip: 'Toggle light and dark',
                ),
              ],
            )
          : null,
      body: onHome
          ? home
          : ProfilePage(onToggleTheme: widget.onToggleTheme),
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
