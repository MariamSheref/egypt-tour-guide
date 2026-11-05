import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final user = UserProvider();
  await user.load();
  runApp(ChangeNotifierProvider.value(value: user, child: const SmartHeritageApp()));
}
