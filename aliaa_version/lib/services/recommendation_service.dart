
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class RecommendationService {
  static const baseUrl = 'http://localhost:8000';

  Future<Map<String, dynamic>> recommend({
    required double budget,
    required int familySize,
    required int childrenCount,
    required double availableHours,
    required String period,
  }) async {
    final enabled = await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      throw Exception('Please enable location services.');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is required.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    final response = await http
        .post(
          Uri.parse('$baseUrl/recommend'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'budget_egp': budget,
            'family_size': familySize,
            'children_count': childrenCount,
            'available_hours': availableHours,
            'period': period,
            'max_radius_km': 25,
            'max_stops': 4,
            'number_of_trips': 3,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception(
        'API error ${response.statusCode}: ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
