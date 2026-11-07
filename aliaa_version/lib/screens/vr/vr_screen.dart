import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';

/// Safe placeholder until actual HTML/360 content is provided.
class VrScreen extends StatelessWidget {
  const VrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final placeName = ModalRoute.of(context)?.settings.arguments as String? ?? 'This place';
    return Scaffold(
      appBar: AppBar(title: const Text('Virtual Tour')),
      backgroundColor: AppColors.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.view_in_ar_outlined, size: 80, color: AppColors.primary),
            const SizedBox(height: 20),
            Text('VR tour coming soon',
                textAlign: TextAlign.center,
                style: AppText.headlineLgMobile(color: AppColors.primary)),
            const SizedBox(height: 12),
            Text('The virtual experience for $placeName will be available when its HTML and 360° content are added.',
                textAlign: TextAlign.center, style: AppText.bodyMd()),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to place details'),
            ),
          ]),
        ),
      ),
    );
  }
}
