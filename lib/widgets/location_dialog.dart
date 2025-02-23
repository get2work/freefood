import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;
import 'dart:async';

@JS('google.maps')
external JSObject get googleMaps;

@JS('google.maps.places')
external JSObject get places;

@JS('google.maps.places.Autocomplete')
@staticInterop
class Autocomplete {
  external factory Autocomplete(web.Element element, JSObject options);
}

extension AutocompleteExtension on Autocomplete {
  external PlaceResult getPlace();
  external void addListener(String event, JSFunction callback);
}

@JS()
@staticInterop
class GoogleMapsPlaces {
  external factory GoogleMapsPlaces();
}

extension GoogleMapsPlacesExtension on GoogleMapsPlaces {
  external JSObject get Autocomplete;
}

@JS()
@staticInterop
class PlaceResult {
  external factory PlaceResult();
}

extension PlaceResultExtension on PlaceResult {
  external PlaceGeometry? get geometry;
  external JSArray get types;
}

@JS()
@staticInterop
class PlaceGeometry {
  external factory PlaceGeometry();
}

extension PlaceGeometryExtension on PlaceGeometry {
  external LatLngLiteral get location;
}

@JS()
@staticInterop
class LatLngLiteral {
  external factory LatLngLiteral();
}

extension LatLngLiteralExtension on LatLngLiteral {
  external num lat();
  external num lng();
}

class LocationDialog extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  const LocationDialog({
    super.key,
    required this.onLocationSelected,
  });

  @override
  State<LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
  final _addressController = TextEditingController();
  Timer? _debounce;
  Autocomplete? _autocomplete;
  final _elementId = 'pac-input-${DateTime.now().millisecondsSinceEpoch}';
  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initAutocomplete();
  }

  void _initAutocomplete() {
    final input = web.HTMLInputElement()
      ..id = _elementId
      ..style.width = '100%'
      ..style.height = '48px'
      ..style.padding = '8px 40px 8px 40px'
      ..style.borderRadius = '24px'
      ..style.border = '1px solid rgba(255, 255, 255, 0.12)'
      ..style.boxSizing = 'border-box'
      ..style.outline = 'none'
      ..style.fontSize = '16px'
      ..style.fontFamily = 'Roboto, sans-serif'
      ..style.backgroundColor = 'rgba(255, 255, 255, 0.08)'
      ..style.color = 'rgba(255, 255, 255, 0.87)'
      ..style.caretColor = '#BB86FC'
      ..placeholder = 'Search for food, healthcare, shelters, or transport'
      ..style.setProperty('placeholder-color', 'rgba(255, 255, 255, 0.6)')
      ..style.transition = 'all 0.2s ease-in-out';

    input.onFocus.listen((_) {
      input.style.backgroundColor = 'rgba(255, 255, 255, 0.12)';
      input.style.border = '1px solid #BB86FC';
      input.style.boxShadow = '0 0 0 1px #BB86FC';
    });

    input.onBlur.listen((_) {
      input.style.backgroundColor = 'rgba(255, 255, 255, 0.08)';
      input.style.border = '1px solid rgba(255, 255, 255, 0.12)';
      input.style.boxShadow = 'none';
    });

    ui_web.platformViewRegistry.registerViewFactory(_elementId, (int viewId) => input);

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      try {
        final options = {
          'types': ['geocode', 'establishment'],
          'componentRestrictions': {'country': 'us'},
          'fields': ['geometry', 'name', 'place_id'],
        }.jsify() as JSObject;

        _autocomplete = Autocomplete(input, options);

        _autocomplete!.addListener(
          'place_changed',
          () {
            if (!mounted) return;

            try {
              final place = _autocomplete!.getPlace();
              final geometry = place.geometry;
              if (geometry != null) {
                final location = geometry.location;
                widget.onLocationSelected(LatLng(
                  location.lat().toDouble(),
                  location.lng().toDouble(),
                ));
                Navigator.of(context).maybePop();
              }
            } catch (e) {
              print('Error handling place selection: $e');
              setState(() => _error = 'Error selecting location');
            }
          }.toJS,
        );
      } catch (e) {
        print('Error initializing autocomplete: $e');
        setState(() => _error = 'Error initializing location search');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return WillPopScope(
      onWillPop: () async => true,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Where would you like to search?',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter a location to search',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              // Search box
              Container(
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: colorScheme.surfaceVariant.withOpacity(0.4),
                ),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned(
                      left: 12,
                      child: Icon(
                        Icons.search_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: HtmlElementView(viewType: _elementId),
                    ),
                  ],
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Cancel any pending futures
    _debounce?.cancel();
    _autocomplete = null;
    _addressController.dispose();
    super.dispose();
  }
}

// Helper extension
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
} 