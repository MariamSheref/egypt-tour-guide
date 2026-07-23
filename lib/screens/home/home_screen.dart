import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/themes/app_theme.dart';
import '../../models/heritage_place.dart';
import '../../providers/user_provider.dart';
import '../../widgets/category_chips.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  void _onNavTap(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/questionnaire');
      return;
    }
    if (index == 2) {
      Navigator.pushNamed(context, '/profile');
      return;
    }
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<UserProvider>().prefs;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        'Smart Heritage',
                        style: AppText.titleLg(color: AppColors.primary),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryContainer,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              Text(
                'Good morning, ${prefs.name}',
                style: AppText.headlineLgMobile(color: AppColors.primary),
              ),

              const SizedBox(height: 8),

              Text(
                'Where shall history take you today?',
                style: AppText.bodyMd(),
              ),

              const SizedBox(height: 20),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search ancient wonders...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const CategoryChips(),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'AI-Recommended Wonders',
                      style: AppText.titleLg(color: AppColors.primary),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/recommendation'),
                    child: Text(
                      'See all',
                      style: AppText.bodyMd(color: AppColors.secondary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 420,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: HeritagePlace.all
                      .take(3)
                      .map((place) => _RecommendationCard(place: place))
                      .toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Quick action — plan journey
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/questionnaire'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: AppColors.navyGradient,
                    borderRadius: BorderRadius.circular(AppRadius.dflt),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: Color(0xffffcc87), size: 32),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plan My Journey',
                            style: AppText.titleLg(color: Colors.white),
                          ),
                          Text(
                            'Get AI-powered recommendations',
                            style: AppText.bodyMd(color: Colors.white70),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white54, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.outline,
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final HeritagePlace place;
  const _RecommendationCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/details', arguments: place.toMap()),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          image: DecorationImage(
            image: AssetImage(place.image),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black54, Colors.transparent],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                place.location,
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                '⭐ ${place.rating}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
