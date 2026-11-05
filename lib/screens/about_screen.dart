import 'package:flutter/material.dart';
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('About Egypt Tour Guide')),
    body: ListView(padding: const EdgeInsets.all(22), children: [
      Icon(Icons.travel_explore, size: 64), SizedBox(height: 16),
      Text('Egypt Tour Guide', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      SizedBox(height: 12),
      Text('Discover landmarks and create personalized itineraries. Trip prices and travel times are estimates; confirm opening hours and admission fees before traveling.'),
      SizedBox(height: 12),
      Text('Landmark cards use freely available Wikipedia thumbnails when available, otherwise distinct illustrated previews. Photography and licensing should be reviewed before publication.'),
      SizedBox(height: 12),
      Text('VR tours are coming soon. Monthly plans are currently a manual-renewal concept; online checkout requires merchant configuration.'),
    ]),
  );
}
