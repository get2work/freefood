import 'package:flutter/material.dart';
import 'package:freefood/models/place.dart';

class PlaceListItem extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;

  const PlaceListItem({
    super.key,
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  place.address,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      place.type == PlaceType.restaurant
                          ? Icons.restaurant
                          : Icons.home,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      place.type == PlaceType.restaurant
                          ? 'Restaurant'
                          : 'Shelter',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (place.rating > 0) ...[
                      const Spacer(),
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        place.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 