import 'package:flutter/material.dart';
import 'package:freefood/models/place.dart';
import 'package:freefood/services/navigation_service.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailsScreen({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              place.address,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (place.phoneNumber.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Phone: ${place.phoneNumber}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Opening Hours',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (place.openingHours.isEmpty)
              const Text('Opening hours not available')
            else
              ...place.openingHours.map(
                (hours) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${hours.day}: ${hours.hours}'),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => NavigationService.navigateToPlace(place),
                icon: const Icon(Icons.directions),
                label: const Text('Get Directions'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 