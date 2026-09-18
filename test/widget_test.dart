import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:iba_app_dev_26/features/api_lecture/pages/api_page.dart';
import 'package:iba_app_dev_26/features/api_lecture/services/posts_api.dart';
import 'package:iba_app_dev_26/features/navigation_lecture/pages/post_detail_page.dart';
import 'package:iba_app_dev_26/features/navigation_lecture/pages/routing_lecture_page.dart';
import 'package:iba_app_dev_26/main.dart';

/// A fake backend for every full-app test below.
///
/// IndexedStack keeps every gallery section alive from the moment the app
/// starts, so the API and Routing lectures fire real requests as soon as
/// `pumpWidget` runs — a real `PostsApi()` would reach for the network in
/// every single test in this file otherwise. This one answers GET/POST/PATCH
/// for `/posts` in whatever shape jsonplaceholder itself would.
PostsApi _fakeApi() {
  final client = MockClient((request) async {
    final segments = request.url.pathSegments; // ['posts'] or ['posts', '1', ...]

    if (request.method == 'POST') {
      final sent = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(jsonEncode({...sent, 'id': 101}), 201);
    }
    if (request.method == 'PATCH') {
      final id = int.parse(segments[1]);
      final sent = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({'id': id, 'userId': 1, 'body': 'Body $id', ...sent}),
        200,
      );
    }
    if (segments.length == 3 && segments[2] == 'comments') {
      final postId = int.parse(segments[1]);
      return http.Response(
        jsonEncode([
          {
            'id': 1,
            'postId': postId,
            'name': 'A reader',
            'email': 'reader@example.com',
            'body': 'Nice post!',
          },
        ]),
        200,
      );
    }
    if (segments.length == 2) {
      final id = int.parse(segments[1]);
      return http.Response(
        jsonEncode({
          'id': id,
          'userId': 1,
          'title': 'Post $id',
          'body': 'Body of post $id',
        }),
        200,
      );
    }

    // GET /posts — the list.
    return http.Response(
      jsonEncode([
        {'id': 1, 'userId': 1, 'title': 'First post', 'body': 'Hello API'},
        {'id': 2, 'userId': 1, 'title': 'Second post', 'body': 'More data'},
      ]),
      200,
    );
  });
  return PostsApi(client: client);
}

void main() {
  testWidgets('gallery opens on Basics and switches sections', (tester) async {
    await tester.pumpWidget(WidgetGalleryApp(api: _fakeApi()));
    await tester.pump(const Duration(seconds: 1)); // flush Advanced's FutureBuilder timer

    expect(find.text('Widget Gallery · Basics'), findsOneWidget);

    await tester.tap(find.text('State').last);
    await tester.pumpAndSettle();

    expect(find.text('Widget Gallery · State'), findsOneWidget);
  });

  testWidgets('the drawer switches sections', (tester) async {
    await tester.pumpWidget(WidgetGalleryApp(api: _fakeApi()));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Advanced'));
    await tester.pumpAndSettle();

    expect(find.text('Widget Gallery \u00b7 Advanced'), findsOneWidget);
  });

  testWidgets('the Profile tab shows the student data', (tester) async {
    await tester.pumpWidget(WidgetGalleryApp(api: _fakeApi()));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.widgetWithText(NavigationDestination, 'Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsWidgets);
    // Appears twice: the collapsed SliverAppBar title and the expanded header.
    expect(find.text('Rao Noman'), findsWidgets);
    expect(find.text('3.62'), findsOneWidget); // CGPA stat

    // The course list sits below the fold on a short test window — scroll
    // the SliverAppBar out of the way to reach it.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('App Development'), findsOneWidget); // a course row
  });

  testWidgets('ApiPage renders a GET list and posts a new one', (tester) async {
    // A fake client so the test never touches the real network: it answers
    // GET with two posts and POST with whatever body it was sent, echoed
    // back under id 101 — exactly what JSONPlaceholder itself does.
    final client = MockClient((request) async {
      if (request.method == 'GET') {
        return http.Response(
          jsonEncode([
            {'id': 1, 'userId': 1, 'title': 'First post', 'body': 'Hello API'},
            {'id': 2, 'userId': 1, 'title': 'Second post', 'body': 'More data'},
          ]),
          200,
        );
      }
      final sent = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(jsonEncode({...sent, 'id': 101}), 201);
    });

    await tester.pumpWidget(
      MaterialApp(home: ApiPage(api: PostsApi(client: client))),
    );
    await tester.pump(); // let the initState GET resolve

    expect(find.text('First post'), findsOneWidget);
    expect(find.text('Second post'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Class demo post');
    await tester.tap(find.widgetWithText(FilledButton, 'POST /posts'));
    await tester.pump(); // start the POST
    await tester.pumpAndSettle(); // let it resolve

    expect(find.text('Server assigned id 101'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Add to list'));
    await tester.pumpAndSettle();

    expect(find.text('Class demo post'), findsOneWidget);
    expect(find.text('Server created post #101'), findsOneWidget); // SnackBar

    // Let the highlight-fade timer and the SnackBar's own timer run out
    // before the test tears the widget tree down.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('push, edit and pop carries data both ways', (tester) async {
    final api = _fakeApi();

    await tester.pumpWidget(
      MaterialApp(
        home: RoutingLecturePage(api: api),
        onGenerateRoute: (settings) {
          if (settings.name == RoutingLecturePage.routeName) {
            final postId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => PostDetailPage(postId: postId, api: api),
            );
          }
          return null;
        },
      ),
    );
    await tester.pumpAndSettle();

    // The lecture banner, diagram and two code blocks push the post list
    // off the first screen — scroll down to reach it before tapping.
    await tester.dragUntilVisible(
      find.text('First post'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    // Technique 1: Navigator.push, id and title passed through the
    // constructor.
    await tester.tap(find.text('First post'));
    await tester.pumpAndSettle();

    expect(find.text('First post'), findsWidgets); // AppBar title + list row underneath
    expect(find.text('Nice post!'), findsOneWidget); // a fetched comment

    // Edit the title, save, and see it come back via pop().
    await tester.tap(find.byTooltip('Edit title'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Edited by a student');
    await tester.tap(find.text('Save and go back'));
    await tester.pumpAndSettle();

    expect(find.text('Edited by a student'), findsOneWidget); // new AppBar title
    expect(find.textContaining('PATCH returned 200'), findsOneWidget); // SnackBar

    await tester.pump(const Duration(seconds: 5)); // flush the SnackBar's timer
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    // Technique 2: the same trip again, this time via a named route.
    await tester.tap(find.widgetWithText(TextButton, 'named').first);
    await tester.pumpAndSettle();

    // No initialTitle travels through a named route's arguments — just the
    // id — so the AppBar falls back to this placeholder until the GET
    // resolves.
    expect(find.text('Post #1'), findsOneWidget);
  });

  testWidgets('setState demo increments, the plain field does not', (tester) async {
    await tester.pumpWidget(WidgetGalleryApp(api: _fakeApi()));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'State'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'setState'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    // The counter changes underneath, but without setState the screen keeps
    // showing the old value — the point of the demo.
    await tester.tap(find.widgetWithText(OutlinedButton, 'without setState'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });
}
