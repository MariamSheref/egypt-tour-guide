
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/recommendation_service.dart';

import '../../providers/user_provider.dart';
import '../../models/heritage_place.dart';
import '../../widgets/landmark_image.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  bool _replanning = false;
  final Set<String> _visitedPlaces = {};

  Future<void> _openBooking(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the official booking page')),
      );
    }
  }

  Future<void> _replaceVisited(String placeName) async {
    if (_replanning) return;
    final consent = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Visited this place?'),
        content: Text('Mark "$placeName" as visited and create a new trip without it?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Replace place')),
        ],
      ),
    );
    if (consent != true || !mounted) return;
    final provider = context.read<UserProvider>();
    final contextData = provider.tripResult?['request_context'];
    if (contextData is! Map) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a new trip to enable replacement.')),
      );
      return;
    }
    final nextVisited = {..._visitedPlaces, placeName};
    setState(() => _replanning = true);
    try {
      final updated = await RecommendationService().replan(
        requestContext: Map<String, dynamic>.from(contextData),
        excludedNames: nextVisited,
      );
      if (!mounted) return;
      final updatedTrips = updated['trips'];
      if (updatedTrips is! List || updatedTrips.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No other trip fits the budget, hours and area. Try a longer time or a wider radius.')),
        );
        return;
      }
      setState(() => _visitedPlaces.add(placeName));
      provider.saveTripResult(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New trip ready — $placeName excluded.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update trip: $error')),
      );
    } finally {
      if (mounted) setState(() => _replanning = false);
    }
  }


  static const Color primaryColor = Color(0xFF163B52);
  static const Color accentColor = Color(0xFFC99746);

  String _display(dynamic value, [String fallback = 'N/A']) {
    if (value == null || value.toString().isEmpty) {
      return fallback;
    }
    return value.toString();
  }

  void _showVR(BuildContext context, String placeName) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.vrpano, color: primaryColor),
            SizedBox(width: 10),
            Text('Virtual Tour'),
          ],
        ),
        content: Text(
          'The VR tour for $placeName will be available soon.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = context.watch<UserProvider>().tripResult;

    final trips = result?['trips'] is List
        ? result!['trips'] as List
        : <dynamic>[];

    final warnings = result?['warnings'] is List
        ? result!['warnings'] as List
        : <dynamic>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          'Your Journey',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: result == null
          ? _emptyState(
              'No trip created yet',
              'Complete the questionnaire to get your trip.',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF163B52),
                        Color(0xFF28667C),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Your Perfect Egyptian Adventure',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Explore recommended trips based on '
                        'your budget, available time and location.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Recommended Trips',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '${trips.length} trips found',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 18),

                if (_replanning) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 14),
                  const Text('Finding another trip without your visited places...'),
                ],
                if (_visitedPlaces.isNotEmpty) ...[
                  Text('Visited places excluded: ${_visitedPlaces.join(', ')}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 14),
                ],

                if (trips.isEmpty)
                  _emptyState(
                    'No suitable trips found',
                    'Try increasing your budget, '
                    'available time or search radius.',
                  ),

                ...trips.asMap().entries.map((entry) {
                  if (entry.value is! Map) {
                    return const SizedBox.shrink();
                  }

                  final trip = Map<String, dynamic>.from(
                    entry.value as Map,
                  );

                  return _buildTripCard(
                    context,
                    trip,
                    entry.key + 1,
                  );
                }),

                if (warnings.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Card(
                    color: const Color(0xFFFFF6E7),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Important Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...warnings.map(
                            (warning) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: 8,
                              ),
                              child: Text(
                                '• $warning',
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildTripCard(
    BuildContext context,
    Map<String, dynamic> trip,
    int tripNumber,
  ) {
    final stops = trip['stops'] is List
        ? trip['stops'] as List
        : <dynamic>[];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.route,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Trip $tripNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${stops.length} Stops',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _infoChip(
                      Icons.groups_outlined,
                      'Group: ${_display(trip['family_size'])} people',
                    ),
                    _infoChip(
                      Icons.account_balance_wallet_outlined,
                      'Total budget: ${_display(trip['group_budget_egp'])} EGP',
                    ),
                    _infoChip(
                      Icons.payments_outlined,
                      'Group tickets: ${_display(trip['total_entry_cost_egp'])} EGP',
                    ),
                    _infoChip(
                      Icons.savings_outlined,
                      'Remaining ticket budget: ${_display(trip['remaining_budget_egp'])} EGP',
                    ),
                    _infoChip(
                      Icons.access_time,
                      '${_display(trip['total_duration_minutes'])} min',
                    ),
                    _infoChip(
                      Icons.directions_car_outlined,
                      '${_display(trip['estimated_total_distance_km'])} km',
                    ),
                    _infoChip(
                      Icons.schedule,
                      'Return: ${_display(trip['estimated_return_time'])}',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Your Itinerary',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                ...stops.asMap().entries.map((entry) {
                  if (entry.value is! Map) {
                    return const SizedBox.shrink();
                  }

                  final stop = Map<String, dynamic>.from(
                    entry.value as Map,
                  );

                  return _buildStopCard(
                    context,
                    stop,
                    entry.key + 1,
                    entry.key == stops.length - 1,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: primaryColor, size: 18),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopCard(
    BuildContext context,
    Map<String, dynamic> stop,
    int index,
    bool isLast,
  ) {
    final name = _display(stop['name'], 'Unknown Place');
    HeritagePlace? photoPlace;
    for (final place in HeritagePlace.all) {
      if (place.name.toLowerCase() == name.toLowerCase()) {
        photoPlace = place;
        break;
      }
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFE4E9EE),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (photoPlace != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LandmarkImage(
                    name: name, fallback: photoPlace.image,
                    width: double.infinity, height: 160,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: accentColor,
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _display(stop['governorate']),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const Divider(),

              _stopInfo(
                Icons.login,
                'Arrival',
                _display(stop['arrival_time']),
              ),

              _stopInfo(
                Icons.logout,
                'Departure',
                _display(stop['departure_time']),
              ),

              _stopInfo(
                Icons.person_outline,
                'Ticket per person (estimated)',
                '${_display(stop['entry_price_per_person_egp'])} EGP',
              ),
              _stopInfo(
                Icons.confirmation_number_outlined,
                'Tickets for whole group',
                '${_display(stop['entry_cost_egp'])} EGP',
              ),

              _stopInfo(
                Icons.directions_car_outlined,
                'Travel from previous',
                '${_display(stop['travel_from_previous_minutes'])} min',
              ),

              const SizedBox(height: 10),

              if (stop['booking_link'] is String &&
                  (stop['booking_link'] as String).startsWith('https://')) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _replanning ? null : () => _openBooking(stop['booking_link'] as String),
                    icon: const Icon(Icons.confirmation_number_outlined),
                    label: const Text('Book Tickets — Official Site'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Tickets are purchased on the venue website, not in this app.',
                    style: TextStyle(color: Colors.black54, fontSize: 11)),
                const SizedBox(height: 10),
              ] else if (stop['entry_is_free'] == true) ...[
                const Text('Free entry — no booking needed',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
              ] else ...[
                const Text('Online booking link not verified; check the venue before visiting.',
                  style: TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _replanning ? null : () => _replaceVisited(name),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Visited? Replace in Trip'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showVR(context, name),
                  icon: const Icon(Icons.vrpano),
                  label: const Text('View VR Tour'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(
                      color: primaryColor,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (!isLast)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Icon(
                  Icons.arrow_downward,
                  color: accentColor,
                  size: 22,
                ),
                SizedBox(height: 5),
                Text(
                  'Next Stop',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 6),
      ],
    );
  }

  Widget _stopInfo(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accentColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String title, String description) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.travel_explore,
              size: 65,
              color: accentColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
