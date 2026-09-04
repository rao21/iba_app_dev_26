import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:iba_app_dev_26/main.dart';

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
