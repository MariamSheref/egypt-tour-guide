import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Tries an exact-title Wikipedia thumbnail. If none is available, uses a
/// UNIQUE local illustrated preview rather than a misleading photo of another place.
class LandmarkImage extends StatelessWidget {
  const LandmarkImage({super.key, required this.name, required this.fallback,
    this.fit = BoxFit.cover, this.width, this.height});

  final String name;
  final String fallback;
  final BoxFit fit;
  final double? width;
  final double? height;
  static final Map<String, Future<String?>> _cache = {};

  static Future<String?> _photo(String name) async {
    try {
      final uri = Uri.https('en.wikipedia.org', '/w/api.php', {
        'action': 'query', 'format': 'json', 'redirects': '1',
        'prop': 'pageimages', 'pithumbsize': '900', 'titles': name,
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return null;
      final pages = (jsonDecode(res.body) as Map)['query']?['pages'] as Map?;
      if (pages == null || pages.isEmpty) return null;
      final page = pages.values.first;
      if (page is Map) {
        final thumbnail = page['thumbnail'];
        if (thumbnail is Map) return thumbnail['source']?.toString();
      }
      return null;
    } catch (_) { return null; }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _cache.putIfAbsent(name, () => _photo(name)),
      builder: (context, snapshot) {
        final photo = snapshot.data;
        if (photo != null) {
          return Image.network(photo, fit: fit, width: width, height: height,
            errorBuilder: (_, __, ___) => Image.asset(fallback,
              fit: fit, width: width, height: height));
        }
        return Image.asset(fallback, fit: fit, width: width, height: height);
      },
    );
  }
}
