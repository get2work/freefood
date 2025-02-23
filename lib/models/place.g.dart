// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Place _$PlaceFromJson(Map<String, dynamic> json) => Place(
      id: json['place_id'] as String,
      name: json['name'] as String,
      latitude: (Place._readLatitude(json, 'latitude') as num).toDouble(),
      longitude: (Place._readLongitude(json, 'longitude') as num).toDouble(),
      address: json['formatted_address'] as String,
      phoneNumber: json['formatted_phone_number'] as String? ?? '',
      openingHours:
          (Place._readOpeningHours(json, 'openingHours') as List<dynamic>)
              .map((e) => OpeningHours.fromJson(e as Map<String, dynamic>))
              .toList(),
      type: $enumDecode(_$PlaceTypeEnumMap, Place._readPlaceType(json, 'type')),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$PlaceToJson(Place instance) => <String, dynamic>{
      'place_id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'formatted_address': instance.address,
      'formatted_phone_number': instance.phoneNumber,
      'openingHours': instance.openingHours,
      'type': _$PlaceTypeEnumMap[instance.type]!,
      'rating': instance.rating,
      'types': instance.types,
      'description': instance.description,
    };

const _$PlaceTypeEnumMap = {
  PlaceType.restaurant: 'restaurant',
  PlaceType.shelter: 'shelter',
};

OpeningHours _$OpeningHoursFromJson(Map<String, dynamic> json) => OpeningHours(
      day: json['day'] as String,
      hours: json['hours'] as String,
    );

Map<String, dynamic> _$OpeningHoursToJson(OpeningHours instance) =>
    <String, dynamic>{
      'day': instance.day,
      'hours': instance.hours,
    };
