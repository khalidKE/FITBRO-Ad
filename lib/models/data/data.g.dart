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
      exercises:
          (json['exercises'] as List<dynamic>)
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

_$WorkoutDataImpl _$$WorkoutDataImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutDataImpl(
      exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
      weights:
          (json['weights'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$WorkoutDataImplToJson(_$WorkoutDataImpl instance) =>
    <String, dynamic>{
      'exercise': instance.exercise,
      'weights': instance.weights,
    };

_$WorkoutSessionImpl _$$WorkoutSessionImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutSessionImpl(
      startTime: DateTime.parse(json['startTime'] as String),
      finishTime: DateTime.parse(json['finishTime'] as String),
      workoutData:
          (json['workoutData'] as List<dynamic>)
              .map((e) => WorkoutData.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$$WorkoutSessionImplToJson(
  _$WorkoutSessionImpl instance,
) => <String, dynamic>{
  'startTime': instance.startTime.toIso8601String(),
  'finishTime': instance.finishTime.toIso8601String(),
  'workoutData': instance.workoutData,
};

_$MealImpl _$$MealImplFromJson(Map<String, dynamic> json) => _$MealImpl(
  name: json['name'] as String,
  ingredients:
      (json['ingredients'] as List<dynamic>).map((e) => e as String).toList(),
  instructions: json['instructions'] as String,
  calories: (json['calories'] as num).toInt(),
  image_url: json['image_url'] as String,
);

Map<String, dynamic> _$$MealImplToJson(_$MealImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'ingredients': instance.ingredients,
      'instructions': instance.instructions,
      'calories': instance.calories,
      'image_url': instance.image_url,
    };
