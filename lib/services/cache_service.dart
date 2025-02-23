import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:freefood/models/place.dart';

class CacheService {
  static const String _placesKey = 'cached_places';
  static const Duration _cacheDuration = Duration(hours: 1);

  static Future<void> cachePlaces(List<Place> places) async {
    final prefs = await SharedPreferences.getInstance();
    final placesJson = places.map((place) => jsonEncode(place)).toList();
    await prefs.setStringList(_placesKey, placesJson);
  }

  static Future<List<Place>> getCachedPlaces() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final placesJson = prefs.getStringList(_placesKey) ?? [];
      return placesJson
          .map((json) => Place.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_placesKey);
    await DefaultCacheManager().emptyCache();
  }

  static Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt('last_cache_update');
    if (lastUpdate == null) return false;

    final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
    return DateTime.now().difference(lastUpdateTime) < _cacheDuration;
  }
} 