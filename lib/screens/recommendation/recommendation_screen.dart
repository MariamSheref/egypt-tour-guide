
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

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
                      Icons.payments_outlined,
                      '${_display(trip['total_entry_cost_egp'])} EGP',
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
                Icons.confirmation_number_outlined,
                'Entry Tickets',
                '${_display(stop['entry_cost_egp'])} EGP',
              ),

              _stopInfo(
                Icons.directions_car_outlined,
                'Travel from previous',
                '${_display(stop['travel_from_previous_minutes'])} min',
              ),

              const SizedBox(height: 10),

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
