// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseImpl _$$ExerciseImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      muscles:
          (json['muscles'] as List<dynamic>).map((e) => e as String).toList(),
      instruction: json['instruction'] as String,
      equipment: json['equipment'] as String,
      difficulty: json['difficulty'] as String,
      image: json['image'] as String,
    );

Map<String, dynamic> _$$ExerciseImplToJson(_$ExerciseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'muscles': instance.muscles,
      'instruction': instance.instruction,
      'equipment': instance.equipment,
      'difficulty': instance.difficulty,
      'image': instance.image,
    };

_$SessionImpl _$$SessionImplFromJson(Map<String, dynamic> json) =>
    _$SessionImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      time: DateTime.parse(json['time'] as String),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$SessionImplToJson(_$SessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'time': instance.time.toIso8601String(),
      'exercises': instance.exercises,
    };
