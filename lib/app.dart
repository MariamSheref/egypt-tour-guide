import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
import 'screens/subscription/subscription_screen.dart';
import 'screens/subscription/payment_history_screen.dart';
import 'screens/about_screen.dart';

class SmartHeritageApp extends StatelessWidget {
  const SmartHeritageApp({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<UserProvider>().language;
    return MaterialApp(
        locale: Locale(language),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],

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
          '/subscriptions': (context) => const SubscriptionScreen(),
          '/payment-history': (context) => const PaymentHistoryScreen(),
          '/about': (context) => const AboutScreen(),
        },
    );
  }
}
