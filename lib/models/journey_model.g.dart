// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JourneyModel _$JourneyModelFromJson(Map<String, dynamic> json) => JourneyModel(
      journeyId: json['journeyId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      cover: json['cover'] as String,
      status: json['status'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String?,
      folderId: json['folderId'] as String?,
      moments: (json['moments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$JourneyModelToJson(JourneyModel instance) =>
    <String, dynamic>{
      'journeyId': instance.journeyId,
      'title': instance.title,
      'description': instance.description,
      'cover': instance.cover,
      'status': instance.status,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'folderId': instance.folderId,
      'moments': instance.moments,
    };