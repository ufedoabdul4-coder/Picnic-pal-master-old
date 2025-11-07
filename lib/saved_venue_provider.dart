import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedVenueProvider extends ChangeNotifier {
  List<String> _savedVenueNames = [];

  List<String> get savedVenueNames => _savedVenueNames;

  SavedVenueProvider() {
    _loadSavedVenues();
  }

  Future<void> _loadSavedVenues() async {
    final prefs = await SharedPreferences.getInstance();
    _savedVenueNames = prefs.getStringList('saved_venues') ?? [];
    notifyListeners();
  }

  bool isVenueSaved(String venueName) {
    return _savedVenueNames.contains(venueName);
  }

  Future<void> toggleSavedVenue(String venueName) async {
    if (isVenueSaved(venueName)) {
      _savedVenueNames.remove(venueName);
    } else {
      _savedVenueNames.add(venueName);
    }
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_venues', _savedVenueNames);
  }
}

// Create a global instance of the provider
final savedVenueProvider = SavedVenueProvider();