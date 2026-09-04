import 'package:flutter/material.dart';

import 'demos/basics_page.dart';
import 'demos/input_page.dart';
import 'demos/layout_page.dart';
import 'demos/list_page.dart';
import 'demos/state_page.dart';

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
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final section = _sections[_index];
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    // IndexedStack keeps every page alive, so a switch away and back does not
    // reset the counters and text fields the class is playing with.
    final body = IndexedStack(
      index: _index,
      children: [for (final s in _sections) s.page],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Widget Gallery · ${section.label}'),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: const Icon(Icons.brightness_6_outlined),
            tooltip: 'Toggle light and dark',
          ),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
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
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            )
          : body,
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                for (final s in _sections)
                  NavigationDestination(icon: Icon(s.icon), label: s.label),
              ],
            ),
    );
  }
}
