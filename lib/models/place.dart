import 'package:json_annotation/json_annotation.dart';

part 'place.g.dart';

@JsonSerializable()
class Place {
  @JsonKey(name: 'place_id')
  final String id;
  final String name;
  @JsonKey(readValue: _readLatitude)
  final double latitude;
  @JsonKey(readValue: _readLongitude)
  final double longitude;
  @JsonKey(name: 'formatted_address')
  final String address;
  @JsonKey(name: 'formatted_phone_number', defaultValue: '')
  final String phoneNumber;
  @JsonKey(readValue: _readOpeningHours)
  final List<OpeningHours> openingHours;
  @JsonKey(readValue: _readPlaceType)
  final PlaceType type;
  @JsonKey(defaultValue: 0.0)
  final double rating;
  final List<String> types;
  final String? description;

  Place({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.phoneNumber,
    required this.openingHours,
    required this.type,
    this.rating = 0.0,
    required this.types,
    this.description,
  });

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
  Map<String, dynamic> toJson() => _$PlaceToJson(this);

  static double _readLatitude(Map json, String key) {
    return (json['geometry']['location']['lat'] as num).toDouble();
  }

  static double _readLongitude(Map json, String key) {
    return (json['geometry']['location']['lng'] as num).toDouble();
  }

  static List<OpeningHours> _readOpeningHours(Map json, String key) {
    if (json['opening_hours'] == null || 
        json['opening_hours']['weekday_text'] == null) {
      return [];
    }
    return (json['opening_hours']['weekday_text'] as List)
        .map((e) => OpeningHours.fromString(e.toString()))
        .toList();
  }

  static PlaceType _readPlaceType(Map json, String key) {
    final types = json['types'] as List;
    return types.contains('restaurant') 
        ? PlaceType.restaurant 
        : PlaceType.shelter;
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Place && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class OpeningHours {
  final String day;
  final String hours;

  OpeningHours({required this.day, required this.hours});

  factory OpeningHours.fromJson(Map<String, dynamic> json) => 
      _$OpeningHoursFromJson(json);
  Map<String, dynamic> toJson() => _$OpeningHoursToJson(this);

  factory OpeningHours.fromString(String text) {
    final parts = text.split(': ');
    return OpeningHours(
      day: parts[0],
      hours: parts.length > 1 ? parts[1] : 'Not available',
    );
  }
}

enum PlaceType { restaurant, shelter } 