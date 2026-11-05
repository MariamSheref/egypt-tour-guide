import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';
import '../models/heritage_place.dart';

class UserProvider extends ChangeNotifier {
  UserPreferences _prefs = const UserPreferences();
  Map<String, dynamic>? _tripResult;
  bool _notificationsEnabled = false;
  String _language = 'en';
  DateTime? _trialStart;
  bool _loaded = false;

  UserPreferences get prefs => _prefs;
  Map<String, dynamic>? get tripResult => _tripResult;
  bool get notificationsEnabled => _notificationsEnabled;
  String get language => _language;
  bool get loaded => _loaded;
  DateTime? get trialStart => _trialStart;

  // UI prototype only. Replace with authenticated server entitlement prior to release.
  int get trialDaysRemaining {
    if (_trialStart == null) return 7;
    final days = DateTime.now().toUtc().difference(_trialStart!).inDays;
    return (7 - days).clamp(0, 7);
  }
  bool get hasAccess => trialDaysRemaining > 0;

  Future<void> load() async {
    final storage = await SharedPreferences.getInstance();
    final saved = storage.getString('profile');
    if (saved != null) {
      try { _prefs = UserPreferences.fromJson(jsonDecode(saved) as Map<String, dynamic>); }
      catch (_) { /* Keep defaults if old profile data is malformed. */ }
    }
    _notificationsEnabled = storage.getBool('notifications') ?? false;
    _language = storage.getString('language') ?? 'en';
    final started = storage.getString('trial_start_utc');
    _trialStart = started == null ? DateTime.now().toUtc() : DateTime.tryParse(started)?.toUtc();
    _trialStart ??= DateTime.now().toUtc();
    if (started == null) await storage.setString('trial_start_utc', _trialStart!.toIso8601String());
    _loaded = true;
    notifyListeners();
  }

  Future<void> savePreferences(UserPreferences newPrefs) async {
    _prefs = newPrefs;
    _tripResult = null;
    notifyListeners();
    final storage = await SharedPreferences.getInstance();
    await storage.setString('profile', jsonEncode(_prefs.toJson()));
  }

  Future<void> setNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool('notifications', value);
  }

  Future<void> setLanguage(String value) async {
    if (value != 'ar' && value != 'en') return;
    _language = value;
    notifyListeners();
    (await SharedPreferences.getInstance()).setString('language', value);
  }

  void saveTripResult(Map<String, dynamic> result) {
    _tripResult = result;
    notifyListeners();
  }

  List<HeritagePlace> get recommendations {
    if (!_prefs.isComplete || _prefs.interests.isEmpty) return HeritagePlace.all;
    return HeritagePlace.all.where((place) =>
      _prefs.interests.any((i) => i.toLowerCase() == place.category.toLowerCase()),
    ).toList();
  }
}
