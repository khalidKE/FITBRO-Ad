import 'package:freezed_annotation/freezed_annotation.dart';

part 'data.freezed.dart';
part 'data.g.dart';

@freezed
class Exercise with _$Exercise {
  const factory Exercise({
    required int id,
    required String name,
    required List<String> muscles,
    required String instruction,
    required String equipment,
    required String difficulty,
    required String image,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
}

@freezed
class Session with _$Session {
  const factory Session({
    required String id,
    required String name,
    required DateTime time,
    required List<Exercise> exercises,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);
}

@freezed
class WorkoutData with _$WorkoutData {
  const factory WorkoutData({
    required Exercise exercise,
    required List<String> weights,
  }) = _WorkoutData;

  factory WorkoutData.fromJson(Map<String, dynamic> json) => _$WorkoutDataFromJson(json);
}

@freezed
class WorkoutSession with _$WorkoutSession {
  const factory WorkoutSession({
    required DateTime startTime,
    required DateTime finishTime,
    required List<WorkoutData> workoutData,
  }) = _WorkoutSession;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);
}

@freezed
class Meal with _$Meal {
  const factory Meal({
    required String name,
    required List<String> ingredients,
    required String instructions,
    required int calories,
    required String image_url,
  }) = _Meal;

  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);
}
