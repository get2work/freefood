import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:freefood/models/place.dart';
import 'package:freefood/services/cache_service.dart';

class PlacesService {
  static const String _apiKey = 'AIzaSyAkN6kA08568tyiHxZgXI3_smHGVuORuWQ';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  static const List<String> _shelterKeywords = [
    'homeless shelter',
    'emergency shelter',
    'transitional housing',
    'social services',
  ];

  static bool _isValidPlace(Place place) {
    // Filter out hotels and lodging
    if (place.types.contains('lodging') || 
        place.types.contains('hotel') ||
        place.name.toLowerCase().contains('hotel')) {
      return false;
    }

    // For shelter type, check if it matches our keywords
    if (place.types.contains('shelter') || place.types.contains('homeless_shelter')) {
      return _shelterKeywords.any((keyword) => 
        place.name.toLowerCase().contains(keyword.toLowerCase()) ||
        (place.description?.toLowerCase().contains(keyword.toLowerCase()) ?? false)
      );
    }

    return true;
  }

  static Future<List<Place>> getNearbyPlaces(Position position) async {
    try {
      if (await CacheService.isCacheValid()) {
        return await CacheService.getCachedPlaces();
      }

      final places = await Future.wait([
        _fetchNearbyPlaces(
          position,
          'establishment',
          keyword: 'homeless shelter',
          radius: 10000,
        ),
      ]);

      final allPlaces = places.expand((x) => x).toList();
      await CacheService.cachePlaces(allPlaces);
      return allPlaces.where((place) {
        return _isValidPlace(place);
      }).toList();
    } catch (e) {
      print('Error fetching nearby places: $e');
      try {
        return await CacheService.getCachedPlaces();
      } catch (_) {
        return [];
      }
    }
  }

  static Future<List<Place>> _fetchNearbyPlaces(
    Position position,
    String type, {
    String? keyword,
    int radius = 5000,
  }) async {
    final params = {
      'location': '${position.latitude},${position.longitude}',
      'radius': radius.toString(),
      'type': type,
      if (keyword != null) 'keyword': keyword,
      'key': _apiKey,
    };

    final uri = Uri.parse('$_baseUrl/nearbysearch/json').replace(
      queryParameters: params,
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch places: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
      throw Exception(data['error_message'] ?? 'Failed to fetch places');
    }

    if (data['status'] == 'ZERO_RESULTS') {
      return [];
    }

    final places = <Place>[];
    for (final result in data['results']) {
      try {
        final details = await _getPlaceDetails(result['place_id']);
        places.add(details);
      } catch (e) {
        print('Error fetching place details: $e');
        // Continue with next place if one fails
        continue;
      }
    }

    return places;
  }

  static Future<Place> _getPlaceDetails(String placeId) async {
    final uri = Uri.parse('$_baseUrl/details/json').replace(
      queryParameters: {
        'place_id': placeId,
        'fields': 'place_id,name,geometry,formatted_address,formatted_phone_number,opening_hours,rating,types',
        'key': _apiKey,
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch place details');
    }

    final data = json.decode(response.body);
    if (data['status'] != 'OK') {
      throw Exception(data['error_message'] ?? 'Failed to fetch place details');
    }

    return Place.fromJson(data['result']);
  }
} 