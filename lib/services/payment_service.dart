import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static const baseUrl = 'http://localhost:8000'; // Chrome on same computer

  Future<bool> isConfigured() async {
    final response = await http.get(Uri.parse('$baseUrl/payments/config'))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return false;
    return (jsonDecode(response.body) as Map)['checkout_configured'] == true;
  }

  Future<String> checkout({required String plan, required String firstName,
    required String lastName, required String email, required String phone}) async {
    final response = await http.post(Uri.parse('$baseUrl/payments/checkout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'plan_id': plan, 'first_name': firstName,
        'last_name': lastName, 'email': email, 'phone': phone}));
    if (response.statusCode != 200) {
      throw Exception('Checkout unavailable (${response.statusCode}). ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final url = Uri.parse(data['checkout_url'] as String);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not open payment provider checkout');
    }
    return data['order_id'] as String;
  }

  Future<Map<String, dynamic>> status(String orderId) async {
    final response = await http.get(Uri.parse('$baseUrl/payments/orders/$orderId'));
    if (response.statusCode != 200) throw Exception('Could not fetch payment status');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
