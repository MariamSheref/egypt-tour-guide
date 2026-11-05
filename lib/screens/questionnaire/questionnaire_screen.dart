
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/themes/app_theme.dart';
import '../../models/user_preferences.dart';
import '../../providers/user_provider.dart';
import '../../services/recommendation_service.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() =>
      _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();

  final _budgetController = TextEditingController();
  final _cityController = TextEditingController();

  String? _duration;
  String _period = 'Morning';
  String _visitorType = 'egyptian';

  int _people = 1;
  bool _children = false;
  int _childrenCount = 0;

  bool _loading = false;

  final Set<String> _interests = {};

  static const _cities = [
    'Cairo',
    'Giza',
    'Alexandria',
    'Qalyubia',
    'Dakahlia',
    'Sharqia',
    'Gharbia',
    'Monufia',
    'Kafr El Sheikh',
    'Beheira',
    'Damietta',
    'Port Said',
    'Ismailia',
    'Suez',
    'North Sinai',
    'South Sinai',
    'Red Sea',
    'Fayoum',
    'Beni Suef',
    'Minya',
    'Assiut',
    'Sohag',
    'Qena',
    'Luxor',
    'Aswan',
    'New Valley',
    'Matrouh',
  ];

  static const _times = [
    '2 Hours',
    '4 Hours',
    '6 Hours',
    '8 Hours',
  ];

  static const _categories = [
    'History',
    'Museums',
    'Architecture',
    'Culture',
    'Adventure',
    'Photography',
  ];

  @override
  void initState() {
    super.initState();

    final prefs = context.read<UserProvider>().prefs;

    _budgetController.text = prefs.budget;
    _cityController.text = prefs.location;

    _duration = _times.contains(prefs.availableTime)
        ? prefs.availableTime
        : null;

    _period = prefs.preferredPeriod == 'Evening'
        ? 'Evening'
        : 'Morning';

    _people = prefs.familyMembers < 1
        ? 1
        : prefs.familyMembers;

    _children = prefs.hasChildren;
    _childrenCount = _children ? prefs.childrenCount.clamp(1, _people) : 0;

    _visitorType = prefs.visitorType == 'international' ? 'international' : 'egyptian';
    _interests.addAll(prefs.interests);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: AppColors.primary,
      ),
      filled: true,
      fillColor: AppColors.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24,
        bottom: 12,
      ),
      child: Text(
        text,
        style: AppText.titleLg(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_loading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_children && _childrenCount > _people) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Children count cannot exceed family size',
          ),
        ),
      );
      return;
    }

    final budget = double.parse(
      _budgetController.text.trim(),
    );

    final availableHours = double.parse(
      _duration!.split(' ').first,
    );

    final prefs = UserPreferences(
      budget: _budgetController.text.trim(),
      location: _cityController.text.trim(),
      availableTime: _duration!,
      preferredPeriod: _period,
      familyMembers: _people,
      hasChildren: _children,
      childrenCount: _children ? _childrenCount : 0,
      visitorType: _visitorType,
      interests: _interests.toList(),
    );

    final account = context.read<UserProvider>();
    if (!account.hasAccess) {
      Navigator.pushNamed(context, '/subscriptions');
      return;
    }
    setState(() {
      _loading = true;
    });

    try {
      final result =
          await RecommendationService().recommend(
        city: _cityController.text.trim(),
        budget: budget,
        familySize: _people,
        childrenCount: _children
            ? _childrenCount
            : 0,
        availableHours: availableHours,
        period: _period.toLowerCase(),
        visitorType: _visitorType,
      );

      if (!mounted) return;

      final userProvider = context.read<UserProvider>();

      userProvider.savePreferences(prefs);
      userProvider.saveTripResult(result);

      Navigator.pushNamed(
        context,
        '/recommendation',
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not create trip: $e',
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Plan Your Journey',
          style: AppText.titleLg(
            color: AppColors.primary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(
            AppSpacing.containerMargin,
          ),
          children: [
            Text(
              'Build your perfect day',
              style: AppText.headlineLgMobile(
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Choose your preferences and '
              'discover trips using your chosen '
              'starting city, budget and time.',
              style: AppText.bodyMd(),
            ),

            // BUDGET AND LOCATION

            _heading('Budget & location'),
            DropdownButtonFormField<String>(
              initialValue: _visitorType,
              decoration: _decoration('Visitor ticket category', Icons.public),
              items: const [
                DropdownMenuItem(value: 'egyptian', child: Text('Egyptian visitor')),
                DropdownMenuItem(value: 'international', child: Text('International visitor')),
              ],
              onChanged: (v) { if (v != null) setState(() => _visitorType = v); },
            ),
            const SizedBox(height: 8),
            const Text('Ticket estimates use the selected adult rate in EGP; verify discounts and current prices at checkout.',
                style: TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 14),

            TextFormField(
              controller: _budgetController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: _decoration(
                'Total group budget (EGP)',
                Icons.wallet_outlined,
              ).copyWith(
                helperText: 'One budget for everyone, not per person. Ticket costs for all travelers must fit inside this amount.',
                helperMaxLines: 3,
              ),
              validator: (value) {
                final amount = double.tryParse(
                  value?.trim() ?? '',
                );

                if (amount == null ||
                    !amount.isFinite ||
                    amount <= 0) {
                  return 'Enter a valid budget greater than zero';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: _cityController,
              textCapitalization:
                  TextCapitalization.words,
              decoration: _decoration(
                'Starting governorate / city',
                Icons.location_on_outlined,
              ).copyWith(
                helperText:
                    'Choose a city or governorate. No GPS permission is required.',
                helperMaxLines: 2,
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Enter your starting location';
                }

                return null;
              },
            ),

            const SizedBox(height: 12),

            Text(
              'Or choose a governorate:',
              style: AppText.bodyMd(),
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 110,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _cities.map((city) {
                    return ActionChip(
                      label: Text(city),
                      onPressed: () {
                        setState(() {
                          _cityController.text = city;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),

            // FAMILY

            _heading('Who is coming?'),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Number of people '
                    '(including children)',
                  ),
                ),

                IconButton(
                  onPressed: _people > 1
                      ? () {
                          setState(() {
                            _people--;

                            if (_childrenCount > _people) {
                              _childrenCount = _people;
                            }
                          });
                        }
                      : null,
                  icon: const Icon(
                    Icons.remove_circle_outline,
                  ),
                ),

                Text(
                  '$_people',
                  style: AppText.titleLg(
                    color: AppColors.primary,
                  ),
                ),

                IconButton(
                  onPressed: _people < 20
                      ? () {
                          setState(() {
                            _people++;
                          });
                        }
                      : null,
                  icon: const Icon(
                    Icons.add_circle_outline,
                  ),
                ),
              ],
            ),

            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Traveling with children',
              ),
              subtitle: const Text(
                'Prioritize family-friendly places',
              ),
              value: _children,
              onChanged: (value) {
                setState(() {
                  _children = value;
                  _childrenCount = value ? 1 : 0;
                });
              },
            ),

            if (_children) ...[
              const SizedBox(height: 12),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Number of children',
                    ),
                  ),

                  IconButton(
                    onPressed: _childrenCount > 1
                        ? () {
                            setState(() {
                              _childrenCount--;
                            });
                          }
                        : null,
                    icon: const Icon(
                      Icons.remove_circle_outline,
                    ),
                  ),

                  Text(
                    '$_childrenCount',
                    style: AppText.titleLg(
                      color: AppColors.primary,
                    ),
                  ),

                  IconButton(
                    onPressed: _childrenCount < _people
                        ? () {
                            setState(() {
                              _childrenCount++;
                            });
                          }
                        : null,
                    icon: const Icon(
                      Icons.add_circle_outline,
                    ),
                  ),
                ],
              ),
            ],

            // TIME

            _heading('When would you like to go?'),

            DropdownButtonFormField<String>(
              initialValue: _duration,
              isExpanded: true,
              decoration: _decoration(
                'Available time',
                Icons.access_time_outlined,
              ),
              items: _times.map((time) {
                return DropdownMenuItem<String>(
                  value: time,
                  child: Text(time),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _duration = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Select available time';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: 'Morning',
                  label: Text('Morning'),
                ),
                ButtonSegment(
                  value: 'Evening',
                  label: Text('Evening'),
                ),
              ],
              selected: {_period},
              onSelectionChanged: (values) {
                setState(() {
                  _period = values.first;
                });
              },
            ),

            // INTERESTS

            _heading('Your interests (optional)'),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((interest) {
                return FilterChip(
                  label: Text(interest),
                  selected:
                      _interests.contains(interest),
                  onSelected: (checked) {
                    setState(() {
                      if (checked) {
                        _interests.add(interest);
                      } else {
                        _interests.remove(interest);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // SUBMIT BUTTON

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _loading
                    ? null
                    : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.route),
                label: Text(
                  _loading
                      ? 'Creating your trip...'
                      : 'Find My Trip',
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
