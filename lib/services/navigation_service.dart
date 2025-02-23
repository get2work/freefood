import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:freefood/models/place.dart';

class NavigationService {
  static Future<void> navigateToPlace(Place place) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw Exception('Could not launch navigation');
    }
  }

  static void showDirectionsDialog(BuildContext context, Place place) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Navigate to Location'),
        content: Text('Would you like to get directions to ${place.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              navigateToPlace(place);
            },
            child: const Text('Navigate'),
          ),
        ],
      ),
    );
  }
} 