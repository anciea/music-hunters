// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SearchResponse _$SearchResponseFromJson(Map<String, dynamic> json) =>
    _SearchResponse(
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => TrackDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      warnings: (json['warnings'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SearchResponseToJson(_SearchResponse instance) =>
    <String, dynamic>{'tracks': instance.tracks, 'warnings': instance.warnings};
