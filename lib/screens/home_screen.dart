import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:freefood/models/place.dart';
import 'package:freefood/providers/theme_provider.dart';
import 'package:freefood/screens/place_details_screen.dart';
import 'package:freefood/services/location_service.dart';
import 'package:freefood/services/places_service.dart';
import 'package:freefood/widgets/place_list_item.dart';
import 'package:freefood/services/map_style_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:freefood/providers/filter_provider.dart';
import 'package:freefood/utils/string_extensions.dart';
import 'package:freefood/widgets/filter_panel.dart';

class HomeScreen extends StatefulWidget {
  final Position? initialPosition;

  const HomeScreen({
    super.key,
    this.initialPosition,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Place> _places = [];
  bool _isLoading = true;
  String? _error;
  Position? _currentPosition;
  Set<Marker> _filteredMarkers = {};

  @override
  void initState() {
    super.initState();
    // Delay initialization to avoid dependency issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  Future<void> _initializeLocation() async {
    try {
      final position = widget.initialPosition ?? await LocationService.getCurrentLocation();
      if (position == null) {
        throw Exception('Could not get current location');
      }

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      // Fetch nearby places
      final places = await PlacesService.getNearbyPlaces(position);
      setState(() {
        _places = places;
        _markers = places.map((place) => _createMarker(place)).toSet();
      });

      // Center map on current location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          14,
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Marker _createMarker(Place place) {
    return Marker(
      markerId: MarkerId(place.id),
      position: LatLng(place.latitude, place.longitude),
      infoWindow: InfoWindow(
        title: place.name,
        snippet: place.address,
        onTap: () => _showPlaceDetails(place),
      ),
    );
  }

  void _showPlaceDetails(Place place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceDetailsScreen(place: place),
      ),
    );
  }

  void _updateMarkers() {
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);
    setState(() {
      if (filterProvider.selectedFilters.isEmpty) {
        _filteredMarkers = {};
        return;
      }

      _filteredMarkers = _markers.where((marker) {
        final place = _places.firstWhere((p) => p.id == marker.markerId.value);
        
        // Check each selected filter
        for (final filter in filterProvider.selectedFilters) {
          if (filter == 'shelter') {
            // Special case for shelters
            if (place.types.contains('homeless_shelter') ||
                place.name.toLowerCase().contains('homeless shelter') ||
                place.name.toLowerCase().contains('emergency shelter')) {
              return true;
            }
          } else {
            // Check other types
            final validTypes = filterProvider.placeTypeMapping[filter]!;
            if (place.types.any((type) => validTypes.contains(type))) {
              return true;
            }
          }
        }
        return false;
      }).toSet();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMarkers();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateMarkers();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filterProvider = Provider.of<FilterProvider>(context);

    // Update markers when filters change
    _updateMarkers();

    final myLocationMarker = Stack(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: 14,
          ),
        ),
      ],
    );

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _currentPosition != null 
          ? Padding(
              padding: EdgeInsets.only(bottom: _places.isNotEmpty ? 216 : 16),
              child: FloatingActionButton(
                onPressed: () {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      16,
                    ),
                  );
                },
                child: const Icon(Icons.my_location),
              ),
            ) 
          : null,
      appBar: AppBar(
        title: Text(
          'FreeFood',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () =>
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: GoogleMap(
              style: Theme.of(context).brightness == Brightness.dark
                  ? MapStyleService.darkStyle
                  : MapStyleService.lightStyle,
              initialCameraPosition: CameraPosition(
                target: _currentPosition != null 
                    ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                    : const LatLng(0, 0),
                zoom: _currentPosition != null ? 14 : 2,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              rotateGesturesEnabled: false,
              markers: {
                if (_currentPosition != null)
                  Marker(
                    markerId: const MarkerId('myLocation'),
                    position: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
                    zIndex: 2,
                  ),
                ..._filteredMarkers,
              },
            ),
          ),
          // Custom position for map controls
          Positioned(
            right: 16,
            bottom: _places.isNotEmpty ? 216 : 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  onPressed: () {
                    _mapController?.animateCamera(
                      CameraUpdate.zoomIn(),
                    );
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  onPressed: () {
                    _mapController?.animateCamera(
                      CameraUpdate.zoomOut(),
                    );
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const FilterPanel(),
                const Spacer(),
                if (_places.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _places.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) => PlaceListItem(
                        place: _places[index],
                        onTap: () => _showPlaceDetails(_places[index]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      ElevatedButton(
                        onPressed: _initializeLocation,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _markers.clear();
    _places.clear();
    super.dispose();
  }
} 