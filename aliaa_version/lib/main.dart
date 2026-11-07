import 'package:egypt_tour_guide/subscription_feature.dart';
import 'package:flutter/material.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SubscriptionService.instance.load();
  runApp(const SmartHeritageApp());
}
