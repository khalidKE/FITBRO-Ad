import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:FitBro/models/data/data.dart';

class DataRepo {
  Future<List<Exercise>> getExercises() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/json/exercises.json',
      );
      List<dynamic> exerciseJson = json.decode(jsonString);
      List<Exercise> exercises =
          exerciseJson
              .map((exerciseJson) => Exercise.fromJson(exerciseJson))
              .toList();
      print(exercises.toString());
      return exercises;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Meal>> getMeals() async {
    try {
      String jsonString = await rootBundle.loadString('assets/json/meals.json');
      List<dynamic> mealJson = json.decode(jsonString);
      List<Meal> meals =
          mealJson.map((mealJson) => Meal.fromJson(mealJson)).toList();
      return meals;
    } catch (e) {
      print(e);
      return [];
    }
  }
}
