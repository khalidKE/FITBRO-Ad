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

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
}

@freezed
class Session with _$Session {
  const factory Session({
    required String id,
    required String name,
    required DateTime time,
    required List<Exercise> exercises,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
}

class WorkoutData {
  final Exercise exercise;
  final List<String> weights;

  WorkoutData({required this.exercise, required this.weights});
}

class WorkoutSession {
  final DateTime startTime;
  final DateTime finishTime;
  final List<WorkoutData> workoutData;

  WorkoutSession({
    required this.startTime,
    required this.finishTime,
    required this.workoutData,
  });
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

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'] as String? ?? '',
      ingredients:
          (json['ingredients'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      instructions: json['instructions'] as String? ?? '',
      calories: json['calories'] as int? ?? 0,
      image_url: json['image_url'] as String? ?? '',
    );
  }
}
