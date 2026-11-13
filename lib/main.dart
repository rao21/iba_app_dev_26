import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/product_explorer/bloc/product_bloc.dart';
import 'features/product_explorer/bloc/product_event.dart';
import 'features/product_explorer/cubit/favorites_cubit.dart';
import 'features/product_explorer/pages/splash_page.dart';
import 'features/product_explorer/services/api_service.dart';
import 'features/product_explorer/widgets/product_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProductBloc(ApiService())..add(const LoadProducts()),
        ),
        BlocProvider(create: (context) => FavoritesCubit()),
      ],
      child: MaterialApp(
        title: 'Product Explorer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: kAccent,
          scaffoldBackgroundColor: kBackground,
          fontFamily: 'Roboto',
        ),
        home: const SplashPage(),
      ),
    );
  }
}
