import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/themes/app_theme.dart';
import '../../models/heritage_place.dart';
import '../../providers/user_provider.dart';
import '../../widgets/category_chips.dart';
import '../../subscription_feature.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => maybeShowSubscribePromo(context),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _category = 'All Sites';

  List<HeritagePlace> get _visiblePlaces {
    final query = _search.trim().toLowerCase();
    return HeritagePlace.all.where((place) {
      final matchesCategory =
          _category == 'All Sites' || place.category == _category;
      final matchesSearch =
          query.isEmpty ||
          place.name.toLowerCase().contains(query) ||
          place.location.toLowerCase().contains(query) ||
          place.category.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _onNavTap(int index) async {
    if (index == 1) {
      if (await requireAccess(context)) {
        if (!mounted) return;
        Navigator.pushNamed(context, '/questionnaire');
      }
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
    final visible = _visiblePlaces;

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
                controller: _searchController,
                onChanged: (value) => setState(() => _search = value),
                decoration: InputDecoration(
                  hintText: 'Search places, governorates, categories...',
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

              CategoryChips(
                selectedCategory: _category,
                onSelected: (value) => setState(() => _category = value),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Discover Heritage Places',
                      style: AppText.titleLg(color: AppColors.primary),
                    ),
                  ),
                  Text(
                    '${visible.length} of ${HeritagePlace.all.length}',
                    style: AppText.bodyMd(color: AppColors.secondary),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              const Text(
                'Browse catalog preview. Some places still need verified prices, photos and opening times.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 35),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 44,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        const Text('No places match your search and filters.'),
                        TextButton(
                          onPressed: () => setState(() {
                            _searchController.clear();
                            _search = '';
                            _category = 'All Sites';
                          }),
                          child: const Text('Clear category filter'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 420,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: visible.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return _RecommendationCard(place: visible[index]);
                    },
                  ),
                ),

              const SizedBox(height: 20),

              // Quick action — plan journey
              GestureDetector(
                onTap: () async {
                  if (await requireAccess(context)) {
                    if (!context.mounted) return;
                    Navigator.pushNamed(context, '/questionnaire');
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: AppColors.navyGradient,
                    borderRadius: BorderRadius.circular(AppRadius.dflt),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Color(0xffffcc87),
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Plan My Journey',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.titleLg(color: Colors.white),
                            ),
                            Text(
                              'Set your budget, time and travel group',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.bodyMd(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white54,
                        size: 16,
                      ),
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
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                place.governorate,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                place.category,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
