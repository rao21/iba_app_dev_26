import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_colors.dart';
import '../providers/product_providers.dart';
import 'home_screen.dart';

/// Waits on [productsProvider]'s first load, then moves on to Home —
/// whether it succeeded or failed, since Home knows how to show its own
/// error state with a retry button.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(productsProvider, (previous, next) {
      final wasLoading = previous == null || previous.isLoading;
      if (wasLoading && !next.isLoading) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });

    return const Scaffold(
      backgroundColor: kAccent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department_rounded, size: 56, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Fakestore Deals',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 28),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
