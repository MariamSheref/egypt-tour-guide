import 'package:flutter/material.dart';
import '../models/user_preferences.dart';
import '../models/heritage_place.dart';

class UserProvider extends ChangeNotifier {
  UserPreferences _prefs = const UserPreferences();

  UserPreferences get prefs => _prefs;

  void savePreferences(UserPreferences prefs) {
    _prefs = prefs;
    notifyListeners();
  }

  List<HeritagePlace> get recommendations {
    if (!_prefs.isComplete) return HeritagePlace.all;

    return HeritagePlace.all.where((place) {
      if (_prefs.interests.isEmpty) return true;
      return _prefs.interests
          .any((i) => i.toLowerCase() == place.category.toLowerCase());
    }).toList()
      ..addAll(
        HeritagePlace.all.where((place) {
          if (_prefs.interests.isEmpty) return false;
          return !_prefs.interests
              .any((i) => i.toLowerCase() == place.category.toLowerCase());
        }),
      );
  }
}
