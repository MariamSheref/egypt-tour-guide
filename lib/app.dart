import 'package:flutter/material.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/details/pyramid_details_screen.dart';


class SmartHeritageApp extends StatelessWidget {
  const SmartHeritageApp({super.key});


  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      initialRoute: '/',

      routes: {

        '/': (context) => const SplashScreen(),

        '/home': (context) => const HomeScreen(),

        '/details': (context) => const PyramidDetailsScreen(),

      },

    );
  }
}