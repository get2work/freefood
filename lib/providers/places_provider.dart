import 'package:flutter/foundation.dart';
import 'package:freefood/models/place.dart';
import 'package:freefood/services/places_service.dart';
import 'package:freefood/services/location_service.dart';
import 'package:freefood/services/cache_service.dart';

class PlacesProvider with ChangeNotifier {
  List<Place> _places = [];
  bool _isLoading = false;
  String? _error;

  List<Place> get places => _places;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPlaces() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (await CacheService.isCacheValid()) {
        _places = await CacheService.getCachedPlaces();
        _isLoading = false;
        notifyListeners();
        return;
      }

      final position = await LocationService.getCurrentLocation();
      if (position == null) {
        throw Exception('Could not get current location');
      }

      _places = await PlacesService.getNearbyPlaces(position);
      await CacheService.cachePlaces(_places);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 