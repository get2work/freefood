import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    try {
      if (kIsWeb) {
        // Web-specific location handling
        final hasPermission = await Geolocator.checkPermission();
        if (hasPermission == LocationPermission.denied) {
          final permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw Exception('Location permission denied');
          }
        }

        // Check if location is enabled
        final isEnabled = await Geolocator.isLocationServiceEnabled();
        if (!isEnabled) {
          throw Exception('Please enable location services in your browser');
        }
      } else {
        // Mobile-specific location handling
        final permission = await Permission.location.request();
        if (!permission.isGranted) {
          throw Exception('Location permission denied');
        }
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
} 