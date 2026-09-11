import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:iba_app_dev_26/demos/api_page.dart';
import 'package:iba_app_dev_26/main.dart';
import 'package:iba_app_dev_26/services/posts_api.dart';

void main() {
  testWidgets('gallery opens on Basics and switches sections', (tester) async {
    await tester.pumpWidget(const WidgetGalleryApp());
    await tester.pump(const Duration(seconds: 1)); // flush Advanced's FutureBuilder timer

    expect(find.text('Widget Gallery · Basics'), findsOneWidget);

    await tester.tap(find.text('State').last);
    await tester.pumpAndSettle();

    expect(find.text('Widget Gallery · State'), findsOneWidget);
  });

  testWidgets('the drawer switches sections', (tester) async {
    await tester.pumpWidget(const WidgetGalleryApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Advanced'));
    await tester.pumpAndSettle();

    expect(find.text('Widget Gallery \u00b7 Advanced'), findsOneWidget);
  });

  testWidgets('the Profile tab shows the student data', (tester) async {
    await tester.pumpWidget(const WidgetGalleryApp());
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

  testWidgets('setState demo increments, the plain field does not', (tester) async {
    await tester.pumpWidget(const WidgetGalleryApp());
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
