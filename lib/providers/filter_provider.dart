import 'package:flutter/material.dart';

class FilterProvider extends ChangeNotifier {
  final Set<String> _selectedFilters = {};
  
  final Map<String, IconData> filterOptions = {
    'food': Icons.restaurant,
    'health': Icons.local_hospital,
    'shelter': Icons.night_shelter,
    'transport': Icons.directions_bus,
  };

  final Map<String, List<String>> placeTypeMapping = {
    'food': [
      'restaurant',
      'meal_takeaway',
      'cafe'
    ],
    'health': [
      'hospital',
      'doctor',
      'health_services'
    ],
    'shelter': [
      'homeless_shelter',
    ],
    'transport': [
      'bus_station',
      'train_station',
      'transit_station',
      'subway_station'
    ],
  };

  Set<String> get selectedFilters => _selectedFilters;

  void toggleFilter(String filter) {
    if (_selectedFilters.contains(filter)) {
      _selectedFilters.remove(filter);
    } else {
      _selectedFilters.add(filter);
    }
    notifyListeners();
  }
} 