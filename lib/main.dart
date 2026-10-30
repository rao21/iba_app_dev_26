import 'package:flutter/material.dart';

import 'features/posts/injector.dart';
import 'features/posts/presentation/pages/posts_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2F6F5E),
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
      ),
      home: PostsPage(getPosts: buildGetPosts()),
    );
  }
}
