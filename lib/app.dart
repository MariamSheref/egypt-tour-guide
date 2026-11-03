import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/themes/app_theme.dart';
import 'providers/user_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/questionnaire/questionnaire_screen.dart';
import 'screens/recommendation/recommendation_screen.dart';
import 'screens/details/pyramid_details_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/vr/vr_screen.dart';

class SmartHeritageApp extends StatelessWidget {
  const SmartHeritageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildSmartHeritageTheme(),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/home': (context) => const HomeScreen(),
          '/questionnaire': (context) => const QuestionnaireScreen(),
          '/recommendation': (context) => const RecommendationScreen(),
          '/details': (context) => const PyramidDetailsScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/vr': (context) => const VrScreen(),
        },
      ),
    );
  }
}
