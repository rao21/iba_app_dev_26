import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/product_bloc.dart';
import '../bloc/product_state.dart';
import '../widgets/product_card.dart';
import 'root_page.dart';

/// Shown while the first product fetch is in flight. A BlocListener moves
/// on to [RootPage] the moment loading finishes — whether it succeeded or
/// failed, since Home itself knows how to show an error state.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (previous, current) => previous.isLoading && !current.isLoading,
      listener: (context, state) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RootPage()),
        );
      },
      child: const Scaffold(
        backgroundColor: kAccent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storefront_rounded, size: 56, color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Product Explorer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
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
      ),
    );
  }
}
