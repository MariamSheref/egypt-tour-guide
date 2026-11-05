import 'dart:convert';
import 'package:http/http.dart' as http;

class RecommendationService {
  static const baseUrl = 'http://localhost:8000';

  Future<Map<String, dynamic>> resolveLocation(String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/locations/resolve'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name.trim()}),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Unknown location: $name. Choose a supported city or governorate.');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> recommend({
    required String city,
    required double budget,
    required int familySize,
    required int childrenCount,
    required double availableHours,
    required String period,
    required String visitorType,
  }) async {
    // A typed city/governorate is the only location input. No GPS permission.
    final origin = await resolveLocation(city);
    final payload = {
      'latitude': origin['latitude'],
      'longitude': origin['longitude'],
      'budget_egp': budget,
      'family_size': familySize,
      'children_count': childrenCount,
      'available_hours': availableHours,
      'period': period,
      'visitor_type': visitorType,
      'max_radius_km': 60,
      'max_stops': 4,
      'number_of_trips': 3,
    };
    final response = await http.post(
      Uri.parse('$baseUrl/recommend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception('Trip API error ${response.statusCode}: ${response.body}');
    }
    final result = jsonDecode(response.body) as Map<String, dynamic>;
    result['origin_note'] = origin['note'];
    return result;
  }

  Future<Map<String, dynamic>> replan({
    required Map<String, dynamic> requestContext,
    required Set<String> excludedNames,
  }) async {
    final payload = Map<String, dynamic>.from(requestContext);
    payload['excluded_places'] = excludedNames.toList();
    final response = await http.post(
      Uri.parse('$baseUrl/recommend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception('Trip update failed (${response.statusCode}): ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
